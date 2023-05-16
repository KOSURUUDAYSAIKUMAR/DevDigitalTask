//
//  CityDetailViewController.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit

protocol CityDetailViewControllerDelegate: AnyObject {
    func getNavigationBar() -> UINavigationBar?
}

class CityDetailViewController: UIViewController, CityDetailViewControllerDelegate {

    // MARK: - Public properties
    var localWeatherData: WeatherModel?
    var colorThemeComponent: ColorThemeModel
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return colorThemeComponent.cityDetails.isStatusBarDark ? .darkContent : .lightContent
    }

    // MARK: - Private properties
    private weak var updateTimer: Timer?
    private lazy var mainView: CityDetailViewProtocol = {
        let view = CityDetailView(colorThemeComponent: colorThemeComponent)
        view.viewControllerOwner = self
        return view
    }()
    
    private lazy var backButtonNavBarItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(backButtonPressed))
        button.tintColor = colorThemeComponent.cityDetails.isStatusBarDark ? .black : .white
        
        return button
    }()

    // MARK: - Lifecycle
    
    init(colorThemeComponent: ColorThemeModel) {
        self.colorThemeComponent = colorThemeComponent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButtonNavBarItem.action = #selector(backButtonPressed)
        backButtonNavBarItem.target = self
        navigationItem.leftBarButtonItem = backButtonNavBarItem

        if let safeWeatherData = localWeatherData {
            let navBarTitleColor: UIColor = colorThemeComponent.cityDetails.isStatusBarDark ? .black : .white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navBarTitleColor]
            title = safeWeatherData.cityName
            
            mainView.updateData(safeWeatherData)
        }

        updateTimer = Timer.scheduledTimer(timeInterval: 10.0,
                                           target: self,
                                           selector: #selector(fetchWeatherData),
                                           userInfo: nil,
                                           repeats: true)
        updateTimer?.fire()
        
        setupBlurableNavBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mainView.viewWillLayoutUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
    }
    
    // MARK: - Functions
    
    func getNavigationBar() -> UINavigationBar? {
        return navigationController?.navigationBar
    }
    
    // MARK: - Private Functions
    
    private func setupBlurableNavBar() {
        getNavigationBar()?.shadowImage = UIImage()
        getNavigationBar()?.setBackgroundImage(UIImage(), for: .default)
        getNavigationBar()?.backgroundColor = .clear
    }

    // MARK: - Actions

    @objc func fetchWeatherData() {
        guard let safeWeatherData = localWeatherData else { return }
        let city = safeWeatherData.cityRequest
        let lat = city.latitude
        let lon = city.longitude
        let appid = Dev.Network.apiKey
        let units = UserDefaultsManager.UnitData.get()
        let params = ["lat": lat,
                      "lon":lon,
                      "appid":appid,
                      "units":units,
                      "eclude":Dev.Network.minutely] as [String : Any]
        didUpdateWeatherDetailsFromServerUpdateUI(parameters: params, at: 0) { success in
            if success { }
        }
    }

    func didUpdateWeatherDetailsFromServerUpdateUI(parameters: [String:Any], at position: Int, completion: @escaping BoolCompletion) -> Void {
        DevListHandler().fetchWisdomeList(index: position, page: parameters) { [self] data, error in
            if error == nil {
                // Display UI Part
                DispatchQueue.main.async { [self] in
                    self.mainView.updateData(data ?? WeatherModel(lat: 0, lon: 0, conditionId: 0, cityName: "", temperature: 0.0, timezone: 0, feelsLike: 0.0, description: "", humidity: 0, uviIndex: 0.0, wind: 0.0, cloudiness: 0, pressure: 0, visibility: 0, sunrise: 0, sunset: 0, daily: [], hourly: []))
                }
            } else {
                // Show error message
                let alert = AlertViewBuilder()
                    .build(title: "Oops", message: error?.localizedDescription ?? "", preferredStyle: .alert)
                    .build(title: "Ok", style: .default, handler: nil)
                    .content
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

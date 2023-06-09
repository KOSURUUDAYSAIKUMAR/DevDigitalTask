//
//  CityListViewController.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 12/05/23.
//

import UIKit
import CoreData

class CityListViewController: UIViewController {
    
    // MARK: - User interface objects
    @IBOutlet weak var cityTableView: UITableView!
    
    // MARK: - ViewController properties
    private let fadeTransitionAnimator = FadeTransitionAnimator()
    private var weatherManager = NetworkHandler()
    private var savedCities = [SavedCity]()
    var dataStorage: DataStorageProtocol?
    var displayWeather: [WeatherModel?] = []
    private var refreshControl = UIRefreshControl()
    let appComponents = AppComponents(UserDefaultsManager.ColorTheme.getCurrentColorTheme())
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Dev.CoreData.modelName)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromCoreData()
        
        // Space before the first cell
        cityTableView.contentInset.top = Grid.pt8 // Getting rid of any delays between user touch and cell animation
        cityTableView.delaysContentTouches = false // Setting up drag and drop delegates
        cityTableView.dragInteractionEnabled = true
        cityTableView.register(LoadingCell.self, forCellReuseIdentifier: Dev.CellIdentifier.cityLoadingCell)
        cityTableView.register(MainMenuTableViewCell.self, forCellReuseIdentifier: Dev.CellIdentifier.cityCell)
        cityTableView.separatorStyle = .none
        cityTableView.translatesAutoresizingMaskIntoConstraints = false
        cityTableView.backgroundColor = .clear
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refreshWeatherData(_:)), for: .valueChanged)
        cityTableView.addSubview(refreshControl)
        fetchWeatherData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if displayWeather.isEmpty {
            // Show Alert message
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Utilities
    func getDataFromCoreData() {
        dataStorage = WeatherCoreDataManager(managedContext: persistentContainer.newBackgroundContext())
    }
    
    @objc func refreshWeatherData(_ sender: AnyObject) {
        fetchWeatherData()
        refreshControl.endRefreshing()
    }
    
    func fetchWeatherData() {
        guard let savedCities = dataStorage?.getSavedItems else {
            return
        }
        self.savedCities = savedCities
        displayWeather.removeAll()
        for _ in 0..<savedCities.count {
            displayWeather.append(nil)
        }
        for (i, city) in savedCities.enumerated() {
            let lat = city.latitude
            let lon = city.longitude
            let appid = Dev.Network.apiKey
            let units = UserDefaultsManager.UnitData.get()
            let params = ["lat": lat,
                          "lon":lon,
                          "appid":appid,
                          "units":units,
                          "eclude":Dev.Network.minutely] as [String : Any]
            didUpdateWeatherDetailsFromServerUpdateUI(parameters: params, at: i) { success in
                if success { }
            }
        }
    }
    
    func didUpdateWeatherDetailsFromServerUpdateUI(parameters: [String:Any], at position: Int, completion: @escaping BoolCompletion) -> Void {
        DevListHandler().fetchWisdomeList(index: position, page: parameters) { [self] data, error in
            if error == nil {
                // Display UI Part
                DispatchQueue.main.async { [self] in
                    displayWeather[position] = data
                    let indexPath = IndexPath(row: position, section: 0)
                    // Put chosen city name from addCity autoCompletion into weather data model
                    displayWeather[indexPath.row]?.cityName = savedCities[indexPath.row].name
                    cityTableView.reloadRows(at: [indexPath], with: .fade)
                }
            } else {
                // Show error message
                let removeEmptyCells: ((UIAlertAction) -> (Void)) = { _ in
                    for (i, weatherModel) in self.displayWeather.enumerated() {
                        if weatherModel != nil {
                            self.dataStorage?.deleteItem(at: i)
                            self.displayWeather.remove(at: i)
                        }
                        self.cityTableView.reloadData()
                    }
                }
                
                DispatchQueue.main.async {
                    let alert = AlertViewBuilder()
                        .build(title: "Oops", message: "Your account is temporary blocked due to exceeding of requests limitation of your subscription type. Please choose the proper subscription https://openweathermap.org/price", preferredStyle: .alert)
                        .build(title: "Ok", style: .default, handler: removeEmptyCells)
                        .content
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func showDetailViewVC() {
        guard let displayWeatherIndex = cityTableView.indexPathForSelectedRow?.row,
              let strongWeatherData = displayWeather[displayWeatherIndex] else {
            let alert = AlertViewBuilder()
                .build(title: "Oops", message: "Something went wrong", preferredStyle: .alert)
                .build(title: "Ok", style: .default, handler: nil)
                .content
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        let destinationVC = CityDetailViewController(colorThemeComponent: appComponents.colorTheme)
        destinationVC.localWeatherData = strongWeatherData
        destinationVC.colorThemeComponent = appComponents.colorTheme
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}

// MARK: - Transition animation
extension CityListViewController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return fadeTransitionAnimator
    }
}

// MARK: - TableView Delegate and Datasource Methods.
extension CityListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let loadingCell = tableView.dequeueReusableCell(withIdentifier: Dev.CellIdentifier.cityLoadingCell) as? LoadingCell else {
            return UITableViewCell()
        }
        
        guard displayWeather[indexPath.row] != nil,
              let weatherDataForCell = displayWeather[indexPath.row],
              var cell = tableView.dequeueReusableCell(withIdentifier: Dev.CellIdentifier.cityCell) as? MainMenuTableViewCell else {
            loadingCell.setupColorTheme(colorTheme: appComponents.colorTheme)
            return loadingCell
        }
        
        let builder = MainMenuCellBuilder()
        let cityName = displayWeather[indexPath.row]?.cityName ?? Dev.Misc.defaultSityName
        let temperature = weatherDataForCell.temperatureString
        let timeZone = TimeZone(secondsFromGMT: weatherDataForCell.timezone)
        cell = builder
            .erase()
            .build(cityLabelByString: cityName)
            .build(degreeLabelByString: temperature)
            .build(timeLabelByTimeZone: timeZone)
            .build(imageByConditionId: weatherDataForCell.conditionId)
            .build(colorThemeModel: appComponents.colorTheme,
                   conditionId: weatherDataForCell.conditionId,
                   isDay: true)
            .build(colorThemeModel: appComponents.colorTheme, conditionId: weatherDataForCell.conditionId)
            .content
        cell.layoutIfNeeded() // Eliminate layouts left from loading cells
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetailViewVC()
    }
    
    // Cell editing
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] _, _, completionHandler in
            displayWeather.remove(at: indexPath.row)
            dataStorage?.deleteItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
            completionHandler(true)
        }
        let imageSize = Grid.pt60
        deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: Dev.ImageName.deleteImage)?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        }
        deleteAction.backgroundColor = UIColor(white: 1, alpha: 0)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    // Cell highlight functions
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MainMenuTableViewCell {
            cell.isHighlighted = true
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MainMenuTableViewCell {
            cell.isHighlighted = false
        }
    }
}

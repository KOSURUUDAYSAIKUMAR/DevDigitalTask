//
//  WeeklyForecastTableView.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit

class WeeklyForecastTableView: UIView {

    // MARK: - Properties

    var tableViewContentHeight: CGFloat {
        tableView.contentSize.height
    }

    // MARK: - Private properties
    
    private var dataSource: WeatherModel?
    private var colorThemeComponent: ColorThemeModel

    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(WeeklyForecastCell.self, forCellReuseIdentifier: Dev.CellIdentifier.dailyForecastCell)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var backgroundView: UIView = {
        let view = UIView()
        DesignManager.setBackgroundStandartShape(layer: view.layer)
        if colorThemeComponent.cityDetails.weeklyForecast.isShadowVisible {
            DesignManager.setBackgroundStandartShadow(layer: view.layer)
        }
        let weeklyColor = colorThemeComponent.cityDetails.weeklyForecast
        view.backgroundColor = weeklyColor.isClearBackground ? .clear : weeklyColor.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Construction

    init(colorThemeComponent: ColorThemeModel) {
        self.colorThemeComponent = colorThemeComponent
        super.init(frame: .zero)

        tableView.dataSource = self
        tableView.delegate = self

        addSubview(backgroundView)
        backgroundView.addSubview(tableView)

        tableView.reloadData()

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public functions

    func reloadData(_ newData: WeatherModel) {
        dataSource = newData
        tableView.reloadData()
    }

    // MARK: - Private functions

    private func setupConstraints() {
        // BackgroundView
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        // TableView
        tableView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Grid.pt20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -Grid.pt20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: Grid.pt20).isActive = true
        tableView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -Grid.pt20).isActive = true
    }
}

extension WeeklyForecastTableView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.daily.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Dev.CellIdentifier.dailyForecastCell) as? WeeklyForecastCell,
              let safeWeatherData = dataSource else {
            return UITableViewCell()
        }
        
        cell.prepareForReuse()
        cell.setupColorTheme(colorThemeComponent)

        let targetWeather = safeWeatherData.daily[indexPath.row]

        // Setting up date
        let date = Date(timeIntervalSince1970: TimeInterval(targetWeather.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: safeWeatherData.timezone)
        dateFormatter.dateFormat = "d EEEE"
        cell.monthLabel.text = dateFormatter.string(from: date)

        // Make first cell bold
        if indexPath.row == 0 {
            cell.monthLabel.text = "Today"
            cell.monthLabel.font = UIFont.systemFont(ofSize: Grid.pt16, weight: .semibold)
        }

        cell.temperatureLabel.text = String(format: "%.0f°", targetWeather.temp.max)
        cell.minTemperatureLabel.text = String(format: "%.0f°", targetWeather.temp.min)

        let conditionId = targetWeather.weather[0].id
        let cellImageName = WeatherModel.getConditionNameBy(conditionId: conditionId)
        let conditionImageBuilder = ConditionImageBuilder()
        let iconColor = colorThemeComponent.getDetailReviewIconColorByConditionId(conditionId)
        cell.conditionImage.image = conditionImageBuilder
            .erase(.defaultColors)
            .build(systemImageName: cellImageName, pointConfiguration: Grid.pt20)
            .buildColor(iconColor)
            .content
        return cell
    }

}

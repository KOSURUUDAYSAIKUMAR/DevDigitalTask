//
//  HourlyForecastView.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit

class HourlyForecastView: UIView {

    // MARK: - Properties
    
    var isCollectionViewStill: Bool {
        !collectionView.isDragging && !collectionView.isDecelerating
    }
    
    // MARK: - Private Properties

    private var dataSource: WeatherModel?
    private var colorThemeComponent: ColorThemeModel

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: Grid.pt52, height: Grid.pt100)
        layout.shouldInvalidateLayout(forBoundsChange: CGRect())
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HourlyCollectionViewCell.self,
                                forCellWithReuseIdentifier: Dev.CellIdentifier.hourlyForecastCell)
        collectionView.backgroundColor = .none
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    // MARK: - Construction

    init(colorThemeComponent: ColorThemeModel) {
        self.colorThemeComponent = colorThemeComponent
        super.init(frame: .zero)
        
        let hourlyColor = colorThemeComponent.cityDetails.hourlyForecast
        backgroundColor = hourlyColor.isClearBackground ? .clear : hourlyColor.backgroundColor
        
        collectionView.delegate = self
        collectionView.dataSource = self

        addSubview(collectionView)

        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        collectionView.reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    func updateDataSource(_ newData: WeatherModel?) {
        if let strongNewData = newData {
            dataSource = strongNewData
        }
        
        collectionView.reloadData()
    }
}

extension HourlyForecastView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.hourlyDisplayData.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let safeWeatherData = dataSource,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Dev.CellIdentifier.hourlyForecastCell, for: indexPath) as? HourlyCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setupColorTheme(colorThemeComponent)

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: safeWeatherData.timezone)

        let targetHourlyForecast = safeWeatherData.hourlyDisplayData[indexPath.row]

        switch targetHourlyForecast {
        case .weatherType(let currentHour):
            let date = Date(timeIntervalSince1970: TimeInterval(currentHour.dt))
            dateFormatter.dateFormat = "h a"

            cell.topLabel.text = indexPath.row == 0 ? "Now" : dateFormatter.string(from: date)
            let conditionId = currentHour.weather[0].id
            let cellImageName = WeatherModel.getConditionNameBy(conditionId: conditionId)
            let iconColor = colorThemeComponent.getDetailReviewIconColorByConditionId(conditionId)
            
            let imageBuilder = ConditionImageBuilder()
            cell.imageView.image = imageBuilder
                .erase(.defaultColors)
                .build(systemImageName: cellImageName, pointConfiguration: Grid.pt20)
                .buildColor(iconColor)
                .content
            cell.bottomLabel.text = String(format: "%.0f°", currentHour.temp)

            return cell

        case .sunState(let sunStete):
            // Setting up time
            let date = Date(timeIntervalSince1970: TimeInterval(sunStete.time))
            dateFormatter.dateFormat = "h:mm a"

            cell.topLabel.text = dateFormatter.string(from: date)
            let imageConfiguration = UIImage.SymbolConfiguration(pointSize: Grid.pt24)
            
            switch sunStete.description {
            case .sunset:
                cell.bottomLabel.text = "Sunset"
                cell.imageView.image = UIImage(systemName: Dev.SystemImageName.sunsetFill, withConfiguration: imageConfiguration) ?? UIImage()
            case .sunrise:
                cell.bottomLabel.text = "Sunrise"
                cell.imageView.image = UIImage(systemName: Dev.SystemImageName.sunriseFill, withConfiguration: imageConfiguration) ?? UIImage()
            }

            cell.imageView.tintColor = colorThemeComponent.cityDetails.iconColors.sun

            return cell
        }
    }

    // Space insets
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: Grid.pt20, bottom: 0, right: Grid.pt20)
    }
}

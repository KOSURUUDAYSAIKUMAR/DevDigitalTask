//
//  CityVM.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 12/05/23.
//

import UIKit

protocol CityVCDelegate: AnyObject {
    var displayWeather: [WeatherModel?] { get set }
    var dataStorage: DataStorageProtocol? { get set }
    
    func didSelectRow()
}

class CityVM: NSObject {

    weak var viewController: CityVCDelegate?
}

extension CityVM: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewController?.displayWeather.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let loadingCell = tableView.dequeueReusableCell(withIdentifier: Dev.CellIdentifier.cityLoadingCell) as? LoadingCell else {
            return UITableViewCell()
        }

        guard viewController?.displayWeather[indexPath.row] != nil,
              let weatherDataForCell = viewController?.displayWeather[indexPath.row],
              var cell = tableView.dequeueReusableCell(withIdentifier: Dev.CellIdentifier.cityCell) as? MainMenuTableViewCell else {
              //    loadingCell.setupColorTheme(colorTheme: colorThemeComponent)
            return loadingCell
        }

    //    let builder = MainMenuCellBuilder()

        let cityName = viewController?.displayWeather[indexPath.row]?.cityName ?? Dev.Misc.defaultSityName
        let temperature = weatherDataForCell.temperatureString
        let timeZone = TimeZone(secondsFromGMT: weatherDataForCell.timezone)
        cell.cityNameLabel.text = cityName

//        cell = builder
//            .erase()
//            .build(cityLabelByString: cityName)
//            .build(degreeLabelByString: temperature)
//            .build(timeLabelByTimeZone: timeZone)
//            .build(imageByConditionId: weatherDataForCell.conditionId)
//            .build(colorThemeModel: colorThemeComponent.colorTheme,
//                   conditionId: weatherDataForCell.conditionId,
//                   isDay: true)
//            .build(colorThemeModel: colorThemeComponent.colorTheme, conditionId: weatherDataForCell.conditionId)
//            .content

        cell.layoutIfNeeded() // Eliminate layouts left from loading cells
        
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewController?.didSelectRow()
    }

    // Cell editing
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completionHandler in

            self.viewController?.displayWeather.remove(at: indexPath.row)
            self.viewController?.dataStorage?.deleteItem(at: indexPath.row)

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

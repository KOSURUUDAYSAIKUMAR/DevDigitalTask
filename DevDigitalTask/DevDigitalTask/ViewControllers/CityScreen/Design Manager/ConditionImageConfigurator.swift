//
//  ConditionImageConfigurator.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit

protocol ConditionImageColorConfiguratorProtocol {
    var makeColorForSunImage: UIColor { get }
    var makeColorForDefaultImage: UIColor { get }
    var makeColorForCloudImage: UIColor { get }
}

struct StandartConditionImageColorConfigurator: ConditionImageColorConfiguratorProtocol {
    var makeColorForSunImage: UIColor { Dev.Colors.WeatherIcons.defaultSunColor }
    var makeColorForDefaultImage: UIColor { Dev.Colors.WeatherIcons.defaultColor }
    var makeColorForCloudImage: UIColor { Dev.Colors.WeatherIcons.defaultColor }
}

struct WhiteConditionImageColorConfigurator: ConditionImageColorConfiguratorProtocol {
    var makeColorForSunImage: UIColor { .white }
    var makeColorForDefaultImage: UIColor { .white }
    var makeColorForCloudImage: UIColor { .white }
}

struct BlackConditionImageColorConfigurator: ConditionImageColorConfiguratorProtocol {
    var makeColorForSunImage: UIColor { .black }
    var makeColorForDefaultImage: UIColor { .black }
    var makeColorForCloudImage: UIColor { .black }
}

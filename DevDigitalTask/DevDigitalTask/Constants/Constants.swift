//
//  Constants.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit

struct Dev {
    struct CoreData {
        static let modelName = "CitiesModel"
        struct City {
            static let entityName = "City"
            static let name = "name"
            static let latitude = "latitude"
            static let longitude = "longitude"
            static let orderPosition = "orderPosition"
        }
    }
    
    struct CellIdentifier {
        static let cityCell = "cityCell"
        static let cityLoadingCell = "cityLoadingCell"
        static let dailyForecastCell = "dailyForecastCell"
        static let hourlyForecastCell = "hourlyForecastCell"
        static let colorThemeCell = "colorThemeCell"
    }

    struct ImageName {
        static let deleteImage = "DeleteAction"
    }
    
    struct SystemImageName {
        static let sunMaxFill = "sun.max.fill"
        static let sunriseFill = "sunrise.fill"
        static let sunsetFill = "sunset.fill"
        static let eyeFill = "eye.fill"
        static let arrowDownLine = "arrow.down.to.line"
        static let wind = "wind"
        static let cloudFill = "cloud.fill"
        static let drop = "drop.fill"
        static let cloudFogFill = "cloud.fog.fill"
        static let cloudSnowFill = "cloud.snow.fill"
        static let cloudRainFill = "cloud.rain.fill"
        static let cloudDrizzleFill = "cloud.drizzle.fill"
        static let cloudBoltFill = "cloud.bolt.fill"
        static let arrowDown = "chevron.compact.down"
        static let arrowUp = "chevron.compact.up"
    }
    
    struct AccessabilityIdentifier {
        static let mainMenuTableViewCell = "MainMenuTableViewCell"
        
        static let settingsButton = "SettingsButton"
        static let searchButton = "SearchButton"
        
        static let addCityCell = "AddCityCell"
        
        static let colorSettingsTableView = "ColorSettingsTableView"
        
        static let settingsUnitSwitch = "SettingsUnitSwitch"
        
        static let settingsTableView = "SettingsTableView"
    }

    struct UserDefaults {
        static let unit = "Unit"
        static let imperial = "imperial"
        static let metric = "metric"
        
        static let currentColorTheme = "currentColorTheme"
        static let colorThemePositionNumber = "colorThemePositionNumber"
        
        static let appIconNumber = "AppIconNumber"
    }

    struct Network {
        static let baseURL = "https://api.openweathermap.org/data/2.5/onecall?"
        static let apiKey = "9cee49e3cfef8ebb98fdd1e8ecf9e748"
        static let lat = "lat="
        static let lon = "lon="
        static let appid = "appid="
        static let units = "units="
        static let exclude = "exclude="
        static let minutely = "minutely"
    }
    
    struct Links {
        static let telegramAppLink = "https://t.me/climaWeather"
        static let telegramAppstoreLink = "itms-apps://itunes.apple.com/app/id686449807"
    }
    
    struct Misc {
        static let defaultSityName = "-"
        static let colorThemeLocalFile = "ColorThemes"
    }

    struct Colors {
        struct Gradient {
            static let day = [UIColor(red: 68 / 255, green: 166 / 255, blue: 252 / 255, alpha: 1).cgColor,
                              UIColor(red: 114 / 255, green: 225 / 255, blue: 253 / 255, alpha: 1).cgColor]
            static let night = [UIColor(red: 9 / 255, green: 7 / 255, blue: 40 / 255, alpha: 1).cgColor,
                                UIColor(red: 30 / 255, green: 94 / 255, blue: 156 / 255, alpha: 1).cgColor]
            static let blank = [UIColor.clear.cgColor]
            static let fog = [UIColor.clear.cgColor]
        }
        
        struct WeatherIcons {
            static let defaultColor = UIColor(red: 121 / 255, green: 199 / 255, blue: 248 / 255, alpha: 1)
            static let defaultSunColor = UIColor(red: 244 / 255, green: 189 / 255, blue: 59 / 255, alpha: 1)
        }
    }
}

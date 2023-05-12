//
//  UserDefaultsManager.swift
//  Weather
//
//  Created by Александр on 20.06.2021.
//

import Foundation

struct UserDefaultsManager {
    struct UnitData {
        static func get() -> String {
            return UserDefaults.standard.string(forKey: Dev.UserDefaults.unit) ?? Dev.UserDefaults.metric
        }

        static func set(with unit: String) {
            if unit == Dev.UserDefaults.imperial || unit == Dev.UserDefaults.metric {
                UserDefaults.standard.setValue(unit, forKey: Dev.UserDefaults.unit)
            }
        }
    }
    
    struct AppIcon {
        static func get() -> Int {
            return UserDefaults.standard.integer(forKey: Dev.UserDefaults.appIconNumber)
        }

        static func set(with num: Int) {
            UserDefaults.standard.setValue(num, forKey: Dev.UserDefaults.appIconNumber)
        }
    }
    
    struct ColorTheme {
        static func getCurrentColorThemeNumber() -> Int {
            return UserDefaults.standard.integer(forKey: Dev.UserDefaults.colorThemePositionNumber)
        }

        static func setChosenPositionColorTheme(with position: Int) {
            UserDefaults.standard.setValue(position, forKey: Dev.UserDefaults.colorThemePositionNumber)
        }
        
        static func getColorTheme(_ num: Int) -> ColorThemeModel {
            let colorThemes = ColorThemeManager.getColorThemes()
            
            if colorThemes.count < num {
                return ColorThemeModel()
            }
            
            return colorThemes[num]
        }
        
        static func getCurrentColorTheme() -> ColorThemeModel {
            let currentColorThemeNumber = self.getCurrentColorThemeNumber()
            
            let colorThemes = ColorThemeManager.getColorThemes()
                
            if currentColorThemeNumber > colorThemes.count {
                return ColorThemeModel()
            }
            
            return colorThemes[currentColorThemeNumber]
        }
    }
}

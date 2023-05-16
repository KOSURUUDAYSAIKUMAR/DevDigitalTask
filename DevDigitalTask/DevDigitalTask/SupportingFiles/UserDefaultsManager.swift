//
//  UserDefaultsManager.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
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
    
    struct ColorTheme {
        static func getCurrentColorThemeNumber() -> Int {
            return UserDefaults.standard.integer(forKey: Dev.UserDefaults.colorThemePositionNumber)
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

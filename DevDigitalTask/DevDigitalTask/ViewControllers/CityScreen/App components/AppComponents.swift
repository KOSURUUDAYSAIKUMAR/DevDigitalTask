//
//  AppComponents.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import Foundation

protocol ColorThemeProtocol {
    var colorTheme: ColorThemeModel { get set }
}

class AppComponents: ColorThemeProtocol {
    var colorTheme: ColorThemeModel
    
    init(_ colorTheme: ColorThemeModel) {
        self.colorTheme = colorTheme
    }
}


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

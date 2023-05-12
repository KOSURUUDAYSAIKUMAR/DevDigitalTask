

import Foundation

class UnitsSettingsCellController: ReloadColorThemeProtocol {

    // MARK: - Properties
    
    let cell: UnitsSettingsCell

    weak var viewControllerOwner: SettingsViewControllerDelegate?
    
    // MARK: - Private properties
    
    let colorThemeComponent: ColorThemeProtocol
    
    // MARK: - Construction
    
    init(colorThemeComponent: ColorThemeProtocol) {
        self.colorThemeComponent = colorThemeComponent
        cell = UnitsSettingsCell(colorThemeComponent: colorThemeComponent)
        cell.delegate = self
    }
    
    // MARK: - Functions

    func reloadColorTheme() {
        cell.reloadColorTheme()
    }
}

extension UnitsSettingsCellController: UnitSwitchCellDelegate {
    func unitSwitchToggled(_ value: Int) {
        switch value {
        case 0:
            UserDefaultsManager.UnitData.set(with: Dev.UserDefaults.metric)
        case 1:
            UserDefaultsManager.UnitData.set(with: Dev.UserDefaults.imperial)
        default:
            break
        }
        
        viewControllerOwner?.refreshMainMenu()
    }
}

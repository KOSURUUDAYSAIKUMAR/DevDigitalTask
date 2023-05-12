

import UIKit

class TelegramChatSupportCellController: TelegramChatSupportDelegate, ReloadColorThemeProtocol {

    // MARK: - Private
    
    let cell: TelegramChatSupportCell
    
    // MARK: - Construction
    
    init(colorThemeComponent: ColorThemeProtocol) {
        cell = TelegramChatSupportCell(colorThemeComponent: colorThemeComponent)
        cell.delegate = self
    }
    
    // MARK: - Functions
    
    func moveToTelegramChat() {
        if let safeUrl = URL.init(string: Dev.Links.telegramAppLink),
            UIApplication.shared.canOpenURL(safeUrl) {
            UIApplication.shared.open(safeUrl)
        } else if let urlAppStore = URL(string: Dev.Links.telegramAppstoreLink),
                    UIApplication.shared.canOpenURL(urlAppStore)  {
            UIApplication.shared.open(urlAppStore)
        }
    }
    
    func reloadColorTheme() {
        cell.reloadColorTheme()
    }
}

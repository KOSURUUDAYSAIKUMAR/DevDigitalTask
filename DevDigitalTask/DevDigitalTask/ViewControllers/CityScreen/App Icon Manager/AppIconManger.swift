//
//  AppIconManger.swift
//  Weather
//
//  Created by Alexander Rubtsov on 18.11.2021.
//

import Foundation
import UIKit

enum BMAppIcon: Int, CaseIterable {
    case classic,
         darkWhiteCloudAppIcon,
         whiteSunAppIcon,
         cornerSun,
         orangeCloud,
         moon,
         yellowSun,
         blueWhiteCloud
    
    var name: String? {
        switch self {
        case .classic:
            return nil
        case .darkWhiteCloudAppIcon:
            return "cloudNight"
        case .whiteSunAppIcon:
            return "sunSet"
        case .cornerSun:
            return "cornerSun"
        case .orangeCloud:
            return "orangeCloud"
        case .moon:
            return "moon"
        case .yellowSun:
            return "yellowSun"
        case .blueWhiteCloud:
            return "blueWhiteCloud"
        }
    }
    
    var preview: UIImage? {
        switch self {
        case .classic:
            return UIImage(named: Dev.ImageName.appIcon)
        case .darkWhiteCloudAppIcon:
            return UIImage(named: Dev.ImageName.darkWhiteCloudAppIcon3x)
        case .whiteSunAppIcon:
            return UIImage(named: Dev.ImageName.whiteSunAppIcon3x)
        case .cornerSun:
            return UIImage(named: Dev.ImageName.cornerSun3x)
        case .orangeCloud:
            return UIImage(named: Dev.ImageName.orangeCloud3x)
        case .moon:
            return UIImage(named: Dev.ImageName.moon3x)
        case .yellowSun:
            return UIImage(named: Dev.ImageName.yellowSun3x)
        case .blueWhiteCloud:
            return UIImage(named: Dev.ImageName.blueWhiteCloud3x)
        }
    }
}

class AppIconManager {
    var current: BMAppIcon {
        return BMAppIcon.allCases.first(where: {
            $0.name == UIApplication.shared.alternateIconName
        }) ?? .classic
        
    }
    
    func setIcon(_ appIcon: BMAppIcon, completion: ((Bool) -> Void)? = nil) {
        guard current != appIcon, UIApplication.shared.supportsAlternateIcons else {
            print(appIcon, UIApplication.shared.supportsAlternateIcons)
            return
        }

        UIApplication.shared.setAlternateIconName(appIcon.name) { error in
            if let error = error {
                print("Error setting alternative app icon \(appIcon.name ?? "???"): \(error.localizedDescription)")
            }
            
            completion?(error != nil)
        }
    }
}

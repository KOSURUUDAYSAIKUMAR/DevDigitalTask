//
//  DesignManager.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit

struct DesignManager {

    // Cell styles
    enum GradientColors {
        case night, day, fog, blank
    }

    // Making proper round corners
    static func setBackgroundStandartShape(layer: CALayer) {
        layer.cornerCurve = CALayerCornerCurve.continuous
        layer.cornerRadius = 20
    }

    // Making shadow
    static func setBackgroundStandartShadow(layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 7
    }
    
    static let standartImageConfiguration = UIImage.SymbolConfiguration(pointSize: 20)

    // Gradient
    static func getStandartGradientColor(withStyle style: GradientColors) -> [CGColor] {
        switch style {
        case .day: return Dev.Colors.Gradient.day
        case .fog: return Dev.Colors.Gradient.fog
        case .night: return Dev.Colors.Gradient.night
        case .blank: return Dev.Colors.Gradient.blank
        }
    }

    // Country id to country emoji flag converter
    static func countryFlag(byCode code: String) -> String {
        let base: UInt32 = 127397
        var result = ""
        for i in code.unicodeScalars {
            result.unicodeScalars.append(UnicodeScalar(base + i.value)!)
        }
        return String(result)
    }
}

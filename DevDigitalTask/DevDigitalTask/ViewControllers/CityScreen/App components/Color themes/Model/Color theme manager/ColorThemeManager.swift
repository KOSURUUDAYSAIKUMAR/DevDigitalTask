//
//  ColorThemeManager.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import Foundation

struct ColorThemeManager {
    
    // MARK: - Public functions
    
    static func getColorThemes() -> [ColorThemeModel] {
        guard let colorThemesFile = readLocalFile(forName: Dev.Misc.colorThemeLocalFile),
              let result = parseJSON(colorThemesFile) else {
            return []
        }
        
        return result
    }
    
    // MARK: - Private functions
    
    static private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    static private func parseJSON(_ colorThemeData: Data) -> [ColorThemeModel]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([ColorThemeData].self, from: colorThemeData)
            
            var result: [ColorThemeModel] = []
            for colorTheme in decodedData {
                result.append(ColorThemeModel(colorThemeData: colorTheme))
            }
            return result
        } catch {
            print(error)
            return nil
        }
    }
}

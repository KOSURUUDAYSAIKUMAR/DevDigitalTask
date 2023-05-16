//
//  Dictionary.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import Foundation

extension Dictionary {
    var queryString: String? {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        let urlString = output.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? output
        output = String(urlString.dropLast())
        return output
    }
}

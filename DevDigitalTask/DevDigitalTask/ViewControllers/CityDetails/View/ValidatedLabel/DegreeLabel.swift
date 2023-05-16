//
//  DegreeLabel.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit

class DegreeLabel: UILabel {
    override var text: String? {
        didSet {
            validateText()
        }
    }
    
    func validateText() {
        if let labelText = text, labelText.first != "-" && labelText.first != " " {
            text = " " + labelText
        }
    }
}

//
//  MapItemTableViewCell.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import MapKit
import UIKit

public class MapItemTableViewCell: UITableViewCell {
    func viewSetup(withMapItem mapItem: MKMapItem, tintColor: UIColor? = nil) {
        textLabel?.text = mapItem.name
        detailTextLabel?.text = mapItem.placemark.title
        imageView?.tintColor = tintColor
    }
}

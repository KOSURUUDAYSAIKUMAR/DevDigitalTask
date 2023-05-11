//
//  PlaceAnnotation.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit
import MapKit

// MARK: - MKAnnotation
class PlaceAnnotation: NSObject, MKAnnotation {
    let mapItem: MKMapItem
    let coordinate: CLLocationCoordinate2D
    let title, subtitle: String?
    
    init(_ mapItem: MKMapItem) {
        self.mapItem = mapItem
        coordinate = mapItem.placemark.coordinate
        title = mapItem.name
        subtitle = nil
    }
}

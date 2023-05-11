//
//  MKSearchDelegate.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit
import MapKit

// MARK: - Protocol
protocol MapKitSearchDelegate {
    
    func mapKitSearch(_ ViewController: TempViewController, mapItem: MKMapItem)

    // Called on the delegate when the search results returned exactly one matching item
    func mapKitSearch(_ ViewController: TempViewController, searchReturnedOneItem mapItem: MKMapItem)
    
    // Called on the delegate when the user taps on one of the items on the list
    func mapKitSearch(_ ViewController: TempViewController, userSelectedListItem mapItem: MKMapItem)
    
    // Called on the delegate when the user taps on the map, and the geocode returns a matching entry
    func mapKitSearch(_ ViewController: TempViewController, userSelectedGeocodeItem mapItem: MKMapItem)

    // Called on the delegate when the user selects an annotation on the map that was added to the map by the search.
    func mapKitSearch(_ ViewController: TempViewController, userSelectedAnnotationFromMap mapItem: MKMapItem)
}

//
//  TempVM.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import Foundation

class TempVM: NSObject {
    static var homeVM = TempVM()
}

enum TableType {
    case searchCompletion
    case mapItem
}

// MARK: - Map Gestures
//@objc private func mapView(isPan gesture: UIPanGestureRecognizer) {
//    switch gesture.state {
//    case .began:
//        searchBar.resignFirstResponder()
//        isUserMapInteracted = true
//        break
//    case .ended:
//        // Add more results on mapView
//        searchRequestInFuture(isMapPan: true)
//        isUserMapInteracted = false
//        break
//    default:
//        break
//    }
//}

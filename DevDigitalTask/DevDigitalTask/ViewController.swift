//
//  ViewController.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 10/05/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager : CLLocationManager!
    var locationPlacemark : CLPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dev Digital"
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
            // Fallback on earlier versions
        }
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager = CLLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        determineCurrentLocation()
        let onLongTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gestureRecognizer:)))
        mapView.addGestureRecognizer(onLongTapGesture)
    }
    
    func determineCurrentLocation() {
        LocationManager.shared.getLocation { [self] (location:CLLocation?, error:NSError?) in
            if let error = error {
                print("Get current location error ----- ", error.localizedDescription)
                return
            }
            guard let location = location else {
                return
            }
            print("get current location latitude ------- ", location.coordinate.latitude, "and longtitude ------ ", location.coordinate.longitude)
            //Setting Region
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
//            mapView.delegate = self
            addPin(location: location.coordinate)
        }
    }
    
    @objc func handleLongGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            let touchLocation = gestureRecognizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            let myPin = MKPointAnnotation()
            myPin.coordinate = locationCoordinate
            myPin.title = "other location"
            myPin.subtitle = "gesture location"
            mapView.addAnnotation(myPin)
        } else {
            return
        }
    }
    
    func addPin(location: CLLocationCoordinate2D) {
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Current Location"
        self.mapView.addAnnotation(objectAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotation = annotation
        guard !(annotation is MKPointAnnotation) else {
            return nil
        }
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        let pinImage = UIImage(named: "ic_custom_location")
        annotationView?.image = pinImage
        return annotationView
    }
    
    func getCurrentAddress() {
        LocationManager.shared.getCurrentReverseGeoCodedLocation(completionHandler: { [self] location, placemark, error in
            if let _ = error {
                return
            }
            guard let _ = location, let placemark = placemark else {
                return
            }
            print(placemark.administrativeArea ?? "")
            print(placemark.name ?? "")
            print(placemark.country ?? "")
            print(placemark.areasOfInterest ?? "")
            print(placemark.isoCountryCode ?? "")
            print(placemark.location ?? "")
            print(placemark.locality ?? "")
            print(placemark.subLocality ?? "")
            print(placemark.postalCode ?? "")
            print(placemark.timeZone ?? "")
            locationPlacemark = placemark
        })
        
    }
}


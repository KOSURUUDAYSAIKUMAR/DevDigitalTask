//
//  ViewController.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 10/05/23.
//

import MapKit
import UIKit
import CoreData

protocol AddCityProtocol {
    func didAddNewCity()
    func didFailAddingNewCityWithError(error: Error?)
}

protocol AddCityViewDelegate: AnyObject {
    var searchCompleter: MKLocalSearchCompleter { get }
    func dismissView()
    func didChoseCity(title: String, subtitle: String)
    func tryToAddCurrentLocation()
}

protocol AddCityDelegate: AddCityProtocol, DataStorageBasicProtocol, AnyObject {}

class TempViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var nearMeParent: UIView!
    @IBOutlet weak var compassParent: UIView!
    @IBOutlet weak var tabView: UIView!
    // MARK: - Bottom Sheet Views & Variables
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    private var stackViewExpandedHeight: CGFloat?
    
    
    // MARK: - Search Variables
    var searchCompletionRequest: MKLocalSearchCompleter? = MKLocalSearchCompleter()
    var searchCompletions = [MKLocalSearchCompletion]()
    var searchRequestFuture: Timer?
    var searchRequest: MKLocalSearch?
    var searchMapItems = [MKMapItem]()
    var geocodeRequestFuture: Timer?
    var mapAnnotations = Set<MKPlacemark>()
    var expandedRatio : CGFloat = 0.45
    open var delegate: MapKitSearchDelegate?
    var nearMe: MKUserTrackingButton?
    public var compass: MKCompassButton?
    
    var tableViewType: TableType = .searchCompletion {
        didSet {
            switch tableViewType {
            case .searchCompletion:
                tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            case .mapItem:
                tableView.separatorInset = UIEdgeInsets(top: 0, left: 67, bottom: 0, right: 0)
            }
            tableView.reloadData()
        }
    }
    var keyboardHeight: CGFloat = 0
    var tableViewPanInitialOffset: CGFloat?
    var tableViewContentHeight: CGFloat {
        return tableView.backgroundView?.bounds.size.height ?? tableView.contentSize.height
    }
    
    var searchBarHeight: CGFloat {
        return searchBar.frame.height
    }
    var searchBarTextField: UITextField? {
        return searchBar.value(forKey: "searchField") as? UITextField
    }
    var searchBarText: String {
        return searchBar.text ?? ""
    }
    var safeAreaInsetsBottom: CGFloat {
        return view.safeAreaInsets.bottom
    }
    var stackViewMaxExpandedHeight: CGFloat {
        return view.frame.height - 160
    }
    var stackViewMaxMapInteractedHeight: CGFloat {
        let ratio = min(expandedRatio, 1.0)
        return max((view.frame.height) * ratio, searchBarHeight)
    }
    
    var tintColor: UIColor? {
        didSet {
            guard tintColor != oldValue else {
                return
            }
            close.tintColor = tintColor
            nearMe?.tintColor = tintColor
            searchBarTextField?.tintColor = tintColor
        }
    }
    var markerTintColor: UIColor? {
        didSet {
            guard markerTintColor != oldValue else {
                return
            }
            if tableViewType == .mapItem {
                tableView.reloadData()
            }
        }
    }
    
    var completionEnabled = true {
        didSet {
            if !completionEnabled {
                searchCompletionRequest = nil
            } else if searchCompletionRequest == nil {
                searchCompletionRequest = MKLocalSearchCompleter()
            }
        }
    }
    var isUserMapInteracted = false {
        didSet {
            if isUserMapInteracted {
                userDidMapInteract()
            }
        }
    }
    var isExpanded = false
    var isDragged = false {
        didSet {
            if isDragged {
                searchBar.resignFirstResponder() // On drag, dismiss Keyboard
            }
        }
    }
    
    convenience init(delegate: MapKitSearchDelegate?) {
        self.init(nibName: "TempViewController", bundle: Bundle(for: TempViewController.self))
        self.delegate = delegate
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - CoreData
    var dataStorage: DataStorageProtocol?
    weak var cityDelegate: AddCityDelegate?
    weak var cityViewdelegate: AddCityViewDelegate?
    private var savedCities = [SavedCity]()
    
    // MARK: - Setup
    override  func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
     //   displayMapView()
        tableSearchView()
        addNotificationCenter()
        tapGestureHandler()
        // Invoke didSet of respective properties.
        self.tintColor = { tintColor }()
        self.markerTintColor = { markerTintColor }()
        determineCurrentLocation()
        if let searchBarTextField = searchBarTextField {
            searchBarTextField.font = UIFont.systemFont(ofSize: 15)
        }
    }
    
    func displayMapView() {
        nearMe = MKUserTrackingButton(mapView: mapView)
        nearMe!.frame.size = CGSize(width: 24, height: 24)
        nearMeParent.addSubview(nearMe ?? MKUserTrackingButton())
        compass = MKCompassButton(mapView: mapView)
        compassParent.addSubview(compass!)
    }
    
    func tableSearchView() {
        searchBar.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(searchBar(isPan:))))
        tableView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(tableView(isPan:))))
        tableView.register(UINib(nibName: "SearchCompletionTableViewCell", bundle: Bundle(for: SearchCompletionTableViewCell.self)), forCellReuseIdentifier: "SearchCompletion")
        tableView.register(UINib(nibName: "MapItemTableViewCell", bundle: Bundle(for: MapItemTableViewCell.self)), forCellReuseIdentifier: "MapItem")
        searchBar.delegate = self
        searchCompletionRequest?.region = mapView.region
        searchCompletionRequest?.delegate = self
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    func addNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func tapGestureHandler() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(mapView(isPan:)))
        pan.delegate = self
        mapView.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(mapView(isPinch:)))
        pinch.delegate = self
        mapView.addGestureRecognizer(pinch)
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapView(isTap:)))
//        tap.delegate = self
        mapView.addGestureRecognizer(tap)
    }
    
    // MARK: - Map Gestures
    
    @objc private func mapView(isPan gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            searchBar.resignFirstResponder()
            isUserMapInteracted = true
            break
        case .ended:
            // Add more results on mapView
            searchRequestInFuture(isMapPan: true)
            isUserMapInteracted = false
            break
        default:
            break
        }
    }
    
    @objc private func mapView(isPinch gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            searchBar.resignFirstResponder()
            isUserMapInteracted = true
            break
        case .ended:
            // Add more results on mapView
            searchRequestInFuture(isMapPan: true)
            isUserMapInteracted = false
            break
        default:
            break
        }
    }
    
    @objc func mapView(isTap gesture: UITapGestureRecognizer) {
        // If tap is coinciding with pan or pinch gesture, don't geocode.
        guard !isUserMapInteracted else {
            geocodeRequestCancel()
            return
        }
        // If typing or tableView scrolled, only resize bottom sheet.
        guard !searchBar.isFirstResponder && tableView.contentOffset.y == 0 else {
            geocodeRequestCancel()
            isUserMapInteracted = true
            isUserMapInteracted = false
            return
        }
        let coordinate = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let myPin = MKPointAnnotation()
        myPin.coordinate = coordinate
        myPin.title = "other location"
        myPin.subtitle = "gesture method"
        mapView.addAnnotation(myPin)
        geocodeRequestInFuture(withLocation: location)
    }
    
    @IBAction func closeDidTap() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
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
            addPin(location: location.coordinate)
        }
    }
    
    func addPin(location: CLLocationCoordinate2D) {
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Current Location"
        self.mapView.addAnnotation(objectAnnotation)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard !isUserMapInteracted else {
            geocodeRequestCancel()
            return true
        }
        // If typing or tableView scrolled, only resize bottom sheet.
        guard !searchBar.isFirstResponder && tableView.contentOffset.y == 0 else {
            geocodeRequestCancel()
            isUserMapInteracted = true
            isUserMapInteracted = false
            return true
        }
        
        let touchLocation = gestureRecognizer.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let myPin = MKPointAnnotation()
        myPin.coordinate = locationCoordinate
        myPin.title = "other location"
        myPin.subtitle = "gesture method"
        mapView.addAnnotation(myPin)
        // If typing or tableView scrolled, only resize bottom sheet.
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        geocodeRequestInFuture(withLocation: location)
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // Recognize added Gesture Recognizer with existing MapView Gesture Recognizers.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func userDidMapInteract() {
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        searchBar.resignFirstResponder()
        if isExpanded, stackViewHeight.constant > stackViewMaxMapInteractedHeight {
            tableViewShow()
        }
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Dev.CoreData.modelName)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
            try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Geocode
    func geocodeRequestInFuture(withLocation location: CLLocation, timeInterval: Double = 1.5, repeats: Bool = false) {
        geocodeRequestCancel()
        geocodeRequestFuture = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { [weak self] _ in
            guard let self = self, !self.isUserMapInteracted else {
                return
            }
            LocationManager.shared.getReverseGeoCodedLocation(location: location, completionHandler: { location, placemark, error in
                let placeMark = [placemark!]
                self.geocodeRequestDidComplete(withPlacemarks: placeMark, error: error)
                WeatherCoreDataManager(managedContext: self.persistentContainer.newBackgroundContext()).addNewItem(placemark?.subLocality ?? "", lat: location?.coordinate.latitude ?? 0.0, long: location?.coordinate.longitude ?? 0.0)
//                self.cityDelegate?.addNewItem(placemark?.subLocality ?? "", lat: location?.coordinate.latitude ?? 0.0, long: location?.coordinate.longitude ?? 0.0)
                guard let savedCities = self.dataStorage?.getSavedItems else {
                    return
                }

                self.savedCities = savedCities
            })
        }
    }
    
    func geocodeRequestDidComplete(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        guard let originalPlacemark = placemarks?.first, let placemark = originalPlacemark.mkPlacemark else {
            return
        }
        let mapItem = MKMapItem(placemark: placemark)
        delegate?.mapKitSearch(self, mapItem: mapItem)
        delegate?.mapKitSearch(self, userSelectedGeocodeItem: mapItem)
    }
    
    func geocodeRequestCancel() {
        geocodeRequestFuture?.invalidate()
    }
    
    // MARK: - Bottom Sheet Gestures
    @objc func searchBar(isPan gesture: UIPanGestureRecognizer) {
        guard tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        let translationY = gesture.translation(in: view).y
        switch gesture.state {
        case .began:
            isDragged = true
        case .ended:
            bottomSheetDidDrag(completedTranslationY: translationY)
            break
        default:
            if translationY > 0 , let stackViewExpandedHeight = stackViewExpandedHeight {
                // Drag down. Can't drag below searchBarHeight
                stackViewHeight.constant = max(stackViewExpandedHeight - translationY, searchBarHeight)
            } else if translationY < 0 {
                // Drag up. Can't drag above stackViewMaxDraggableHeight
                if let stackViewExpandedHeight = stackViewExpandedHeight, isExpanded {
                    // stackViewExpandedHeight always contains keyboardHeight
                    stackViewHeight.constant = min(stackViewMaxExpandedHeight, stackViewExpandedHeight - translationY)
                } else {
                    stackViewHeight.constant = min(stackViewMaxExpandedHeight, searchBarHeight + keyboardHeight - translationY)
                }
            }
            break
        }
    }
    
    @objc func tableView(isPan gesture: UIPanGestureRecognizer) {
        guard tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        let translationY = gesture.translation(in: view).y
        switch gesture.state {
        case .began:
            isDragged = true
            tableViewPanInitialOffset = tableView.contentOffset.y
            break
        case .ended:
            bottomSheetDidDrag(completedTranslationY: translationY)
            // If bounced bottom, rebounce upwards
            if tableView.contentOffset.y > tableViewContentHeight - tableView.frame.size.height {
                tableView.setContentOffset(CGPoint(x: 0, y: max(0, tableViewContentHeight - tableView.frame.size.height)), animated: true)
            }
            tableViewPanInitialOffset = nil
            break
        default:
            guard let tableViewPanInitialOffset = tableViewPanInitialOffset else {
                return
            }
            let stackViewTranslation = tableViewPanInitialOffset - translationY
            tableView.contentOffset.y = max(0, stackViewTranslation)
            
            //Removed this code because scroll down in the table view hides the table when hitting the top, undesired behavior
            //if stackViewTranslation < 0, let stackViewExpandedHeight = stackViewExpandedHeight {
            //    stackViewHeight.constant = max(searchBarHeight, stackViewExpandedHeight + stackViewTranslation)
            //}
        }
    }
    
    private func bottomSheetDidDrag(completedTranslationY translationY: CGFloat) {
        isDragged = false
        if let stackViewExpandedHeight = stackViewExpandedHeight { // Has expanded.
            if isExpanded { // If already expanded
                if stackViewExpandedHeight < 100 && translationY > 5 {
                    tableViewHide() // If bottom sheet height <100 and dragged down 5 pixels
                } else if stackViewHeight.constant > (stackViewExpandedHeight * 0.85) {
                    tableViewShow() // If dragged down < 15%
                } else {
                    tableViewHide() // If dragged down >= 15%
                }
            } else {
                if stackViewExpandedHeight < 100 && translationY < -5 {
                    tableViewShow() // If bottom sheet height <100 and dragged up 5 pixels
                } else if stackViewHeight.constant > (stackViewExpandedHeight * 0.15) {
                    tableViewShow() // If dragged up > 15%
                } else {
                    tableViewHide() // If dragged up <= 15%
                }
            }
        } else {
            tableViewHide()
        }
    }
}
// MARK: - Map Delegate
extension TempViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        geocodeRequestCancel()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if view == nil {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            marker.markerTintColor = markerTintColor
            marker.clusteringIdentifier = "MapItem"
            view = marker
        }
        return view
    }
    
    // Locates the PlaceAnnotation from an item on the map
    func findPlaceAnnotation(from mapItem: MKMapItem) -> PlaceAnnotation? {
        for annotation in mapView.annotations {
            if let placeAnnotation = annotation as? PlaceAnnotation {
                if placeAnnotation.mapItem == mapItem {
                    return placeAnnotation
                }
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        geocodeRequestCancel()
        //If pressed on one of the annotation, let the delegate know
        if let annotation = view.annotation as? PlaceAnnotation {
            delegate?.mapKitSearch(self, userSelectedAnnotationFromMap: annotation.mapItem)
        }
    }
    
    func centerAndZoomMapOnLocation(_ location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: 1000,
                                                  longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Deselect all annotations on map
    func deselectAnnotations() {
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
}


// MARK: - Search Delegate
extension TempViewController: UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompletionRequest(didComplete: completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchRequestFuture?.invalidate()
        if !searchText.isEmpty {
            searchCompletionRequest?.queryFragment = searchText
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchCompletionRequest?.cancel()
        searchRequestFuture?.invalidate()
        searchRequestStart(dismissKeyboard: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchRequestStart(dismissKeyboard: true)
    }
}

// MARK: - Table Data Source
extension TempViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewType {
        case .searchCompletion:
            return searchCompletions.count
        case .mapItem:
            return searchMapItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewType {
        case .searchCompletion:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCompletion", for: indexPath) as! SearchCompletionTableViewCell
            cell.viewSetup(withSearchCompletion: searchCompletions[indexPath.row])
            return cell
        case .mapItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapItem", for: indexPath) as! MapItemTableViewCell
            cell.viewSetup(withMapItem: searchMapItems[indexPath.row], tintColor: markerTintColor ?? UIColor.red)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}

// MARK: - Table View Delegate
extension TempViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableViewType {
        case .searchCompletion:
            guard searchCompletions.count > indexPath.row else {
                return
            }
            searchBar.text = searchCompletions[indexPath.row].title
            let selectedCity = searchCompletions[indexPath.row]
//            cityViewdelegate?.didChoseCity(title: selectedCity.title,
//                                   subtitle: selectedCity.subtitle)
            searchBarSearchButtonClicked(searchBar)
            break
        case .mapItem:
            guard searchMapItems.count > indexPath.row else {
                return
            }
            let selectedMapItem = searchMapItems[indexPath.row]
            
            //Find the annotation on the map from the selected table entry, zoom to it, hide the table, and let delegate know
            if let placeAnnotation = findPlaceAnnotation(from: selectedMapItem) {
                centerAndZoomMapOnLocation(placeAnnotation.coordinate)
                tableViewHide()
                delegate?.mapKitSearch(self, mapItem: selectedMapItem)
                delegate?.mapKitSearch(self, userSelectedListItem: selectedMapItem)
            }
            
            break
        }
    }
}

extension TempViewController {
    // MARK: - Search Completions
    // Search Completions Request are invoked on textDidChange in searchBar,
    // and region is updated upon regionDidChange in mapView.
    private func searchCompletionRequest(didComplete searchCompletions: [MKLocalSearchCompletion]) {
        searchRequestCancel()
        self.searchCompletions = searchCompletions
        tableViewType = .searchCompletion
        tableViewShow()
    }
    
    private func searchCompletionRequestCancel() {
        searchCompletionRequest?.delegate = nil
        searchCompletionRequest?.region = mapView.region
        searchCompletionRequest?.delegate = self
    }
    
    // MARK: - Search Map Item
    // TODO: Function too coupled with map gestures, create two functions or rename.
    private func searchRequestInFuture(withTimeInterval timeInterval: Double = 2.5, repeats: Bool = false, dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        searchRequestCancel()
        // We use count of 1, as we predict search results won't change.
        if isExpanded, searchMapItems.count > 1, !searchBarText.isEmpty {
            searchRequestFuture = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { [weak self] _ in
                self?.searchRequestStart(dismissKeyboard: dismissKeyboard, isMapPan: isMapPan)
            }
        }
    }
    
    private func searchRequestCancel() {
        searchCompletionRequest?.cancel()
        searchRequestFuture?.invalidate()
        searchRequest?.cancel()
    }
    
    private func searchRequestStart(dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        searchRequestCancel()
        guard !searchBarText.isEmpty else {
            searchBar.resignFirstResponder()
            searchMapItems.removeAll()
            tableView.reloadData()
            tableViewHide()
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            self?.searchRequestDidComplete(withResponse: response, error, dismissKeyboard: dismissKeyboard, isMapPan: isMapPan)
        }
        self.searchRequest = search
    }
    
    private func searchRequestDidComplete(withResponse response: MKLocalSearch.Response?, _ error: Error?, dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        guard let response = response else {
            return
        }
        self.searchMapItems = response.mapItems
        self.tableViewType = .mapItem
        if isMapPan { // Add new annotations from dragging and searching new areas.
            var newAnnotations = [PlaceAnnotation]()
            for mapItem in response.mapItems {
                if !mapAnnotations.contains(mapItem.placemark) {
                    mapAnnotations.insert(mapItem.placemark)
                    newAnnotations.append(PlaceAnnotation(mapItem))
                }
            }
            mapView.addAnnotations(newAnnotations)
        } else { // Remove annotations, and resize mapView to new annotations.
            tableViewShow()
            mapAnnotations.removeAll()
            mapView.removeAnnotations(mapView.annotations)  //remove all annotations from map
            var annotations = [PlaceAnnotation]()
            for mapItem in response.mapItems {
                mapAnnotations.insert(mapItem.placemark)
                annotations.append(PlaceAnnotation(mapItem))
            }
            // 1 Search Result. Refer to delegate.
            if response.mapItems.count == 1, let mapItem = response.mapItems.first {
                delegate?.mapKitSearch(self, mapItem: mapItem)
                delegate?.mapKitSearch(self, searchReturnedOneItem: mapItem)
                
            }
            mapView.showAnnotations(annotations, animated: true)
            if dismissKeyboard {
                searchBar.resignFirstResponder()
            }
        }
    }
}


// MARK: - Bottom Sheet Animations
extension TempViewController {
    
    func tableViewHide(duration: TimeInterval = 0.5,
                       options: UIView.AnimationOptions = [.curveEaseOut]) {
        if keyboardHeight > 0 { // If there was a previous keyboard height from dragging
            if stackViewExpandedHeight != nil, stackViewExpandedHeight! > 0 {
                stackViewExpandedHeight! -= keyboardHeight
            }
            keyboardHeight = 0
        }
        isExpanded = false
        if mapView.frame.size.height > CGFloat(searchBarHeight) {
            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                self.stackViewHeight.constant = CGFloat(self.searchBarHeight)
                if self.searchMapItems.isEmpty {
                    self.stackViewExpandedHeight = nil
                }
                self.tableView.superview?.layoutIfNeeded()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func tableViewShow(duration: TimeInterval = 0.5,
                       options: UIView.AnimationOptions = [.curveEaseInOut]) {
        isExpanded = true
        // If user is interacting with map, or showing mapItems without searching or scrolling tableView, expand bottomSheet to maxMapInteractedHeight.
        let stackViewMaxExpandedHeight = isUserMapInteracted || (tableViewType == .mapItem && !searchBar.isFirstResponder && tableView.contentOffset.y == 0) ? stackViewMaxMapInteractedHeight : self.stackViewMaxExpandedHeight
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            let safeAreaInsetsBottom = self.keyboardHeight > 0 ? self.safeAreaInsetsBottom : 0
            // Remove safeAreaInsets bottom if keyboard opened due to overlap.
            self.stackViewHeight.constant = min(stackViewMaxExpandedHeight, self.searchBarHeight + self.keyboardHeight + self.tableViewContentHeight - safeAreaInsetsBottom)
            self.stackViewExpandedHeight = self.stackViewHeight.constant
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Keyboard Animations
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        keyboardHeight = keyboardFrame.cgRectValue.size.height
        tableViewShow(duration: duration, options: UIView.AnimationOptions(rawValue: curve))
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard !isDragged,
              let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        keyboardHeight = 0
        if isExpanded { // Maintain expanded state, but lower sheet if needed.
            tableViewShow(duration: duration, options: UIView.AnimationOptions(rawValue: curve))
        } else {
            tableViewHide(duration: duration, options: UIView.AnimationOptions(rawValue: curve))
        }
    }
}


extension TempViewController: AddCityDelegate {
    func didAddNewCity() {
    }
    
    func didFailAddingNewCityWithError(error: Error?) {
        
    }
    
    func deleteItem(at index: Int) {
        dataStorage?.deleteItem(at: index)
    }
    
    func rearrangeItems(at firstIndex: Int, to secondIndex: Int) {
        dataStorage?.rearrangeItems(at: firstIndex, to: secondIndex)
    }
    
    var getSavedItems: [SavedCity]? {
        return dataStorage?.getSavedItems
    }

    func addNewItem(_ city: String, lat: Double, long: Double) {
        dataStorage?.addNewItem(city, lat: lat, long: long)
    }
}



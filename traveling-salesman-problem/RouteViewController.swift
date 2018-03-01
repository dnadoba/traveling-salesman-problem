//
//  ViewController.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 06/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Cocoa
import MapKit
import CoreLocation

private let annotationIdentifier = "pin"
private let nameColumnIdentifier = NSUserInterfaceItemIdentifier("NameColumnID")
private let nameCellIdentifier = "NameCellID"

private let embedRouteSummaryControllerSegueIdentifier = NSStoryboardSegue.Identifier("EmbedRouteSummaryController")

private let allColumnIndices: IndexSet = [0]

class RouteViewController: NSViewController, MKMapViewDelegate, NSTableViewDataSource, NSTableViewDelegate, WaypointManagerDelegate, WaypointCellViewDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var waypointTableView: NSTableView!
    @IBOutlet weak var waypointManagerStatusLabel: NSTextField!
    @IBOutlet weak var routeCalcuationAlgorithmSelectionButton: NSPopUpButton!
    @IBOutlet weak var touchbarStatusLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    weak var routeSummaryController: RouteSummaryController!
    
    
    var clickGestureRecognizer: NSClickGestureRecognizer!
    
    var waypointManager = WaypointManager()
    @objc var selectedWaypoint: Waypoint?
    
    let mapPadding = NSEdgeInsets(top: 60, left: 60, bottom: 60, right: 60)
    @objc var transportType: Int = 0 {
        didSet {
            self.waypointManager.routeTransportType = MKDirectionsTransportType(fromSelectedIndex: transportType)
        }
    }
    @objc var routeWeight: Int = 1 {
        didSet {
            self.waypointManager.routeWeight = RouteWeight(fromSelectedIndex: routeWeight)
        }
    }
    @objc var shouldRequestAlternativRoutes: Bool = true {
        didSet {
            waypointManager.requestsAlternateRoutes = shouldRequestAlternativRoutes
        }
    }
    @objc var routeCalculationAlgorithm: Int = 0 {
        didSet {
            guard let option = RouteCalculationAlgorithm(rawValue: routeCalculationAlgorithm) else {
                return
            }
            waypointManager.routeCalculationAlgorithm = option
        }
    }
    
    @IBAction func setAsStart(_ sender: NSButton) {
        print("set as start")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        waypointManager.delegate = self
        
        map.delegate = self
        
        waypointTableView.dataSource = self
        waypointTableView.delegate = self
        
        let gestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(addAnotation(_:)))
        gestureRecognizer.isEnabled = false
        map.addGestureRecognizer(gestureRecognizer)
        clickGestureRecognizer = gestureRecognizer
        
        let deleteMenuItem = NSApplication.shared.mainMenu?.item(withTag: 2)?.submenu?.item(withTag: 100)
        
        deleteMenuItem?.target = self
        deleteMenuItem?.action = #selector(deleteSelectedWaypoint)
        
        updateStateMangerStatusUI(state: waypointManager.state)
        routeCalcuationAlgorithmSelectionButton.removeAllItems()
        
        let titles = RouteCalculationAlgorithm.all.map { $0.description }
        
        routeCalcuationAlgorithmSelectionButton.addItems(withTitles: titles)
        
        progressIndicator.isHidden = true
    }
    
    func resolveRouteCalculationErrorBetween(source: Waypoint, and destination: Waypoint, reason error: Error, resolve: @escaping (RouteCalculationResolveAction) -> ()) {
        
        let alert = NSAlert(error: error)
        alert.informativeText = "Could not calculate Route from \(source.name) to \(destination.name)"
        alert.addButton(withTitle: "Retry")
        alert.addButton(withTitle: "Remove Destination")
        alert.addButton(withTitle: "Remove Source")
        
        alert.beginSheetModal(for: view.window!) { (response) in
            switch response {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                resolve(.retry)
            case NSApplication.ModalResponse.alertSecondButtonReturn:
                resolve(.removeDestination)
            case NSApplication.ModalResponse.alertThirdButtonReturn:
                resolve(.removeSource)
            default:
                resolve(.retry)
            }
        }
    }
    
    @objc func deleteSelectedWaypoint() {
        guard let selectedWaypoint = selectedWaypoint else {
            return
        }
        deselectWaypoint()
        waypointManager.remove(selectedWaypoint)
    }
    
    func didAdd(waypoint: Waypoint) {
        //index of the appended waypoint
        let rowIndex = waypointManager.rowIndex(for: waypoint)!
        
        //update map
        self.map.addAnnotation(waypoint)
        //update table
        waypointTableView.beginUpdates()
        waypointTableView.insertRows(at: [rowIndex], withAnimation: NSTableView.AnimationOptions.slideDown)
        waypointTableView.endUpdates()
    }
    
    func didUpdate(waypoint: Waypoint) {
        // update map
        if let view = map.view(for: waypoint) as? MKPinAnnotationView {
            updateView(view, for: waypoint)
        }
        
        //update table
        guard let rowIndex = waypointManager.rowIndex(for: waypoint) else {
            print("cannot update waypoint \(waypoint) which is not present in the model")
            return
        }
        
        waypointTableView.reloadData(forRowIndexes: [rowIndex], columnIndexes: allColumnIndices)
    }
    
    func willRemove(waypoint: Waypoint) {
        guard let rowIndex = waypointManager.rowIndex(for: waypoint) else {
            print("cannot remove waypoint \(waypoint) which is not present in the model")
            return
        }
        //update map
        self.map.removeAnnotation(waypoint)
        //update table
        waypointTableView.beginUpdates()
        waypointTableView.removeRows(at: [rowIndex], withAnimation: NSTableView.AnimationOptions.slideUp)
        waypointTableView.endUpdates()
    }
    func didRemove(waypoint: Waypoint) {
        
    }
    
    func didCalcuate(routes: [Route], from source: Waypoint, to destination: Waypoint) {
        if let selectedWaypoint = selectedWaypoint {
            guard source == selectedWaypoint else {
                return
            }
        } else {
            map.removeOverlays(map.overlays)
        }
        
        routes.map{$0.polyline}.forEach(map.add)
        
        
    }
    func didCalucate(shortesPath: [Route]) {
        deselectWaypoint()
        map.removeOverlays(map.overlays)
        let overlays = shortesPath.map {
            return $0.polyline
        }
        map.addOverlays(overlays)
        
        let mapRects = overlays.map({ $0.boundingMapRect })
        map.setVisibleMapRects(mapRects, edgePadding: mapPadding, animated: true)
        
        let routeSummary = RouteSummary(routes: shortesPath)
        routeSummaryController.routeSummary = routeSummary
        
    }
    
    func didChangeWaypointManagerState(from oldState: WaypointManagerState, to newState: WaypointManagerState) {
        updateStateMangerStatusUI(state: newState)
    }
    func didChangeRouteCalculationsProgress(progress: Double) {
        progressIndicator.doubleValue = progress
        progressIndicator.isHidden = progress >= 1
    }
    
    private func updateStateMangerStatusUI(state: WaypointManagerState) {
        waypointManagerStatusLabel.stringValue = state.description
        touchbarStatusLabel.stringValue = state.shortDescription
    }
    
    func selectWaypoint(_ waypoint: Waypoint) {
        guard let rowIndex = waypointManager.rowIndex(for: waypoint) else {
            print("cannot select waypoint \(waypoint) because it is not present in the model")
            return
        }
        
        selectedWaypoint = waypoint
        
        //select annotaion on map
        let selectedWaypointsOnMap = map.selectedAnnotations.compactMap { (annotation) -> Waypoint? in
            return annotation as? Waypoint
        }
        //only select if it is not already selected
        if !selectedWaypointsOnMap.contains(where: { $0 == waypoint }) {
            map.selectAnnotation(waypoint, animated: true)
        }
        //select waypoint in table
        //only select if it is not already selected
        if waypointTableView.selectedRow != rowIndex {
            waypointTableView.selectRowIndexes([rowIndex], byExtendingSelection: false)
        }
        
        if let routes = waypointManager.routesStarting(from: waypoint) {
            print(routes.count)
            map.removeOverlays(map.overlays)
            let overlays = routes.map{ (route) -> MKPolyline in
                return route.polyline
            }
            map.addOverlays(overlays)
        }
    }
    
    func deselectWaypoint() {
        selectedWaypoint = nil
        //deselect annotaion on map
        for selectedAnnotaiton in map.selectedAnnotations {
            map.deselectAnnotation(selectedAnnotaiton, animated: true)
        }
        waypointTableView.deselectAll(self)
        showCalculatedRouteIfFound()
    }
    
    func showCalculatedRouteIfFound() {
        map.removeOverlays(map.overlays)
        guard case(.calculatedBestPath(let path)) = waypointManager.state else {
            return
        }
        let overlays = path.map{ (route) -> MKPolyline in
            return route.polyline
        }
        map.addOverlays(overlays)
    }
    
    @IBOutlet weak var addButton: NSButton!
    var modifyingAnotationsEnabled = false {
        didSet {
            clickGestureRecognizer.isEnabled = modifyingAnotationsEnabled
        }
    }
    @IBAction func toogleAddAnotationState(_ sender: NSButton) {
        modifyingAnotationsEnabled = sender.state == .on
    }
    @objc func addAnotation(_ sender: NSClickGestureRecognizer) {
        guard modifyingAnotationsEnabled else {
            return
        }
        let clickLocation = sender.location(in: map)
        let coordinate = map.convert(clickLocation, toCoordinateFrom: map)
        
        let waypoint = Waypoint(location: coordinate)
        
        waypointManager.add(waypoint)
        
        
    }
    
    func setAsStartWaypoint(_ cell: WaypointCellView, waypoint: Waypoint) {
        waypointManager.setAsStartWaypoint(waypoint)
    }
    
    // MARK: Map View Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //return nil for the user location to use the default view
        if annotation is MKUserLocation {
            return nil
        }
        let view = map.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView ?? MKPinAnnotationView(annotation: nil, reuseIdentifier: annotationIdentifier)
        
        view.annotation = annotation
        view.animatesDrop = true
        view.canShowCallout = true
        
        
        if let waypoint = annotation as? Waypoint {
            updateView(view, for: waypoint)
        }
        
        return view
    }
    
    private func updateView(_ view: MKPinAnnotationView, for annotation: Waypoint) {
        let isStart = waypointManager.startWaypoint == annotation
        view.pinTintColor = isStart ? MKPinAnnotationView.greenPinColor() : MKPinAnnotationView.redPinColor()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            print("annotation view selected without an annoation")
            return
        }
        guard let waypoint = annotation as? Waypoint else {
            print("annotation \(annotation) selected which is not a waypoint")
            return
        }
        selectWaypoint(waypoint)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        deselectWaypoint()
    }
    //route renderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = #colorLiteral(red: 0.06485579908, green: 0.5960159898, blue: 0.9942656159, alpha: 1)
        return renderer
    }
    // MARK: Table View Delegate and Data Source
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return waypointManager.waypoints.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else {
            return nil
        }
        let waypoint = waypointManager.waypointForRow(at: row)!
        
        switch tableColumn.identifier {
        case nameColumnIdentifier:
            guard let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: nameCellIdentifier), owner: nil) as? WaypointCellView else {
                return nil
            }
            view.delegate = self
            view.waypoint = waypoint
            view.isStartWaypoint = waypoint == waypointManager.startWaypoint
            
            
            return view
        default:
            return nil
        }
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let waypoint = waypointManager.waypointForRow(at: waypointTableView.selectedRow) else {
            deselectWaypoint()
            return
        }
        selectWaypoint(waypoint)
    }
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == embedRouteSummaryControllerSegueIdentifier,
            let controller = segue.destinationController as? RouteSummaryController {
            routeSummaryController = controller
        }
    }

}

fileprivate extension WaypointManager {
    func rowIndex(for waypoint: Waypoint) -> Int? {
        return waypoints.index(of: waypoint)
    }
    func waypointForRow(at index: Int) -> Waypoint? {
        return waypoints[safe: index]
    }
}

fileprivate extension RouteWeight {
    init(fromSelectedIndex selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            self = .time
        case 1: fallthrough
        default:
            self = .distance
        }
    }
}

fileprivate extension MKDirectionsTransportType {
    init(fromSelectedIndex selectedIndex: Int) {
        switch selectedIndex {
        case 1:
            self = .walking
        case 2:
            self = [.walking, .transit]
        case 0: fallthrough
        default:
            self = .automobile
        }
    }
}

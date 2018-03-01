//
//  WaypointManager.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 08/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit

protocol WaypointManagerDelegate: class {
    func didAdd(waypoint: Waypoint)
    func didUpdate(waypoint: Waypoint)
    func didCalcuate(routes: [Route], from source: Waypoint, to destination: Waypoint)
    func didCalucate(shortesPath: [Route])
    func didChangeWaypointManagerState(from oldState: WaypointManagerState, to newState: WaypointManagerState)
    func willRemove(waypoint: Waypoint)
    func didRemove(waypoint: Waypoint)
    func resolveRouteCalculationErrorBetween(source: Waypoint, and destination: Waypoint, reason error: Error, resolve: @escaping (RouteCalculationResolveAction) -> ())
    func didChangeRouteCalculationsProgress(progress: Double)
}

struct RouteWorkItem {
    let source: Waypoint
    let destination: Waypoint
}

enum RouteRequestResult {
    case successful([Route])
    case throttled(TimeInterval)
    case error(Error)
}

enum RouteCalculationResolveAction {
    case retry
    case removeSource
    case removeDestination
}

/// A Manager for a set of `Waypoint`s. 
/// It automaticlly requests information, like the name of a location, 
/// for all added `Wayoints`s and calculates all `Route`s between all `Waypoint`s.
/// After it has calculated all routes it calculates the best order to visit all `Waypoint`s.
class WaypointManager {
    
    /// All waypoints added to the the manager
    private(set) var waypoints: [Waypoint] = []
    private var graph = WeightedGraph<Waypoint, Route>()
    private let geocoder = CLGeocoder()
    weak var delegate: WaypointManagerDelegate?
    
    /// Queue to sequenzially calculating routes between two `Waypoint`s
    private let routeCalculationQueue = WorkQueue<RouteWorkItem>()
    
    /// count of started route calucations, used to determine the progress
    private(set) var currentStartedRouteCalcuations = 0 {
        didSet {
            delegate?.didChangeRouteCalculationsProgress(progress: currentRouteCalculationProgress)
        }
    }
    
    /// count of finished route calucaitons, used to determin the progress
    private(set) var currentFinishedRouteCalucations = 0 {
        didSet {
            delegate?.didChangeRouteCalculationsProgress(progress: currentRouteCalculationProgress)
        }
    }
    var currentRouteCalculationProgress: Double {
        guard currentStartedRouteCalcuations != 0 else {
            return 1
        }
        return Double(currentFinishedRouteCalucations)/Double(currentStartedRouteCalcuations)
    }
    
    var routeCount: Int {
        return graph.edgeCount
    }
    
    var routeWeight = RouteWeight.distance {
        didSet {
            guard oldValue != routeWeight else {
                return
            }
            graph.edges.forEach { (route) in
                route.weightedBy = routeWeight
            }
            update()
        }
    }
    var routeTransportType = MKDirectionsTransportType.automobile {
        didSet {
            guard oldValue != routeTransportType else { return }
            recaluculateAllRoutes()
        }
    }
    var requestsAlternateRoutes = true {
        didSet {
            guard oldValue != requestsAlternateRoutes else { return }
            recaluculateAllRoutes()
        }
    }
    var routeCalculationAlgorithm: RouteCalculationAlgorithm = .automatic {
        didSet {
            guard oldValue != routeCalculationAlgorithm else { return }
            update()
        }
    }
    
    private (set) var startWaypoint: Waypoint?
    
    /// Current state of the manager
    var state = WaypointManagerState.configurating {
        didSet {
            guard oldValue != state else {
                return
            }
            delegate?.didChangeWaypointManagerState(from: oldValue, to: state)
        }
    }
    
    init() {
        routeCalculationQueue.workCallback = self.calculateRoute
        routeCalculationQueue.queueStateDidChange = self.routeCalculationStateChanged
    }
    
    /// Adds the given `Waypoint` to the manager
    ///
    /// - Parameter waypoint: `Waypoint` to add to the manager
    func add(_ waypoint: Waypoint) {
        waypoints.append(waypoint)
        graph.insertVertex(waypoint)
        if startWaypoint == nil {
            startWaypoint = waypoint
        }
        delegate?.didAdd(waypoint: waypoint)
        
        requestPlacemark(for: waypoint) { [weak self] (placemark) in
            waypoint.placemark = placemark
            
            self?.delegate?.didUpdate(waypoint: waypoint)
        }
        
        calculateRoutesBetweenOtherWaypoints(fromAndTo: waypoint)
        update()
    }
    
    private func requestPlacemark(for waypoint: Waypoint, callback: @escaping (MKPlacemark) -> ()) {
        let location = CLLocation(latitude: waypoint.coordinate.latitude, longitude: waypoint.coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let geoPlacemark = placemarks?.first else {
                if let error = error {
                    print("error while fetching gecode for \(waypoint)")
                    print(error)
                } else {
                    print("could not get a geolocation for \(waypoint)")
                }
                return
            }
            let placemark = MKPlacemark(placemark: geoPlacemark)
            
            callback(placemark)
        }
    }
    
    func setAsStartWaypoint(_ newStartWaypoint: Waypoint?) {
        let oldStartWaypoint = startWaypoint
        guard oldStartWaypoint != newStartWaypoint else {
            //start waypoint did't changed
            return
        }
        startWaypoint = newStartWaypoint
        
        //notify about changes
        delegate.then { (delegate) in
            let changedWaypoints = [oldStartWaypoint, newStartWaypoint].compactMap({$0})
            changedWaypoints.forEach(delegate.didUpdate)
        }
        update()
    }
    
    func remove(_ waypoint: Waypoint) {
        delegate?.willRemove(waypoint: waypoint)
        let stoppedCalculations = routeCalculationQueue.remove{
            return $0.source == waypoint || $0.destination == waypoint
        }
        currentStartedRouteCalcuations -= stoppedCalculations
        waypoints.removeFirst(waypoint)
        graph.remove(waypoint)
        if waypoint == startWaypoint {
            setAsStartWaypoint(waypoints.first)
        }
        update()
        delegate?.didRemove(waypoint: waypoint)
        
    }
    
    func routesStarting(from waypoint: Waypoint) -> Set<Route>? {
        return graph.edges(from: waypoint)
    }
    
    private func update() {
        switch routeCalculationQueue.state {
        case .idle:
            if graph.hasAllRequiredRoutes() {
                calculateBestPath()
            } else {
                state = .configurating
            }
        case .pausing(let date):
            state = .calculatingRoutes(.init(queued: routeCalculationQueue.count, throtteled: .until(date)))
        case .working:
            state = .calculatingRoutes(.init(queued: routeCalculationQueue.count, throtteled: .none))
        }
    }
    
    private func routeCalculationStateChanged(from oldState: WorkQueueState, to newState: WorkQueueState) {
        if newState == .idle {
            currentStartedRouteCalcuations = 0
            currentFinishedRouteCalucations = 0
        }
        update()
    }
    
    private func recaluculateAllRoutes() {
        //cancel all 
        routeCalculationQueue.removeAll()
        //remove all routes
        graph.removeAllEdges(keepingCapacity: true)
        //calculate routes between all waypoints, back and forth
        let workItems = waypoints.flatMap({ (waypoint) -> [RouteWorkItem] in
            //not between the same waypoint
            return waypoints.filter({ (otherWaypoint) -> Bool in
                return waypoint != otherWaypoint
            }).map({ (otherWaypoint) -> RouteWorkItem in
                
                return RouteWorkItem(source: waypoint, destination: otherWaypoint)
            })
        })
        routeCalculationQueue.append(contentsOf: workItems)
        currentStartedRouteCalcuations += workItems.count
    }
    
    private func calculateRoutesBetweenOtherWaypoints(fromAndTo newWaypoint: Waypoint) {
        
        let otherWaypoints = waypoints.filter { $0 != newWaypoint }
        let workItems = otherWaypoints.flatMap { (otherWaypoint) -> [RouteWorkItem] in
            return [
                RouteWorkItem(source: otherWaypoint, destination: newWaypoint),
                RouteWorkItem(source: newWaypoint, destination: otherWaypoint),
            ]
        }
        routeCalculationQueue.append(contentsOf: workItems)
        currentStartedRouteCalcuations += workItems.count
    }
    
    private func didCalculate(routes: [Route], from source: Waypoint, to destination: Waypoint) {
        routes.forEach{ graph.insertEdge($0) }
        self.delegate?.didCalcuate(routes: routes, from: source, to: destination)
        update()
    }
    
    private func calculateRoute(queue: WorkQueue<RouteWorkItem>, on item: RouteWorkItem) {
        routeBetween(source: item.source, destination: item.destination) { [weak self] (result) in
            switch result{
            case .successful(let routes):
                self?.currentFinishedRouteCalucations += 1
                queue.finishWork(on: item)
                self?.didCalculate(routes: routes, from: item.source, to: item.destination)
                
                
            case .throttled(let duration):
                print("throttled for duration: \(duration)")
                queue.pauseWork(for: duration)
                queue.push(item)
            case .error(let error):
                print("could not get directions for route between source \(item.source) and destination \(item.destination)")
                
                print(error)
                guard let delegate = self?.delegate else {
                    queue.finishWork(on: item)
                    return
                }
                delegate.resolveRouteCalculationErrorBetween(source: item.source, and: item.destination, reason: error) { (action) in
                    switch action {
                    case .retry:
                        queue.push(item)
                    case .removeDestination:
                        self?.remove(item.destination)
                    case .removeSource:
                        self?.remove(item.source)
                    }
                    queue.finishWork(on: item)
                }
                
            }
            
        }
    }
    
    func routeBetween(source: Waypoint, destination: Waypoint, callback: @escaping (RouteRequestResult) -> ()) {
        let request = MKDirectionsRequest()
        request.source = source.mapitem
        request.destination = destination.mapitem
        request.requestsAlternateRoutes = requestsAlternateRoutes
        request.transportType = routeTransportType
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    if let error = error as? MKError,
                        let duration = error.throttleStateResetTimeRemaining {
                            
                        callback(.throttled(duration))
                    } else {
                        callback(.error(error))
                    }
                }
                return
            }
            print("Routes count \(response.routes.count)")
            guard !response.routes.isEmpty else {
                print("did get a response but not a route between source \(source) and destination \(destination)")
                
                return
            }
            let routes = response.routes.map{
                return Route(source: source, destination: destination, mkRoute: $0, weightedBy: self.routeWeight)
            }
            callback(.successful(routes))
        }
    }
    
    private func calculateBestPath() {
        guard state != .calculatingBestPath else {
            return
        }
        guard waypoints.count >= 2 else {
            return
        }
        guard let start = startWaypoint else {
            return
        }
        state = .calculatingBestPath
        
        let algorithm = routeCalculationAlgorithm.getPathAlgorithm(for: self)
        guard let shortestPath = graph.calculatePath(from: start, byUsing: algorithm) else {
            state = .configurating
            return
        }
        state = .calculatedBestPath(shortestPath.2)
        delegate?.didCalucate(shortesPath: shortestPath.2)
    }
    
}

fileprivate extension WeightedGraph {
    func hasAllRequiredRoutes() -> Bool {
        for source in vertices {
            let otherVertices = vertices.filter({ $0 != source})
            for destination in otherVertices {
                if !containsEdge(from: source, to: destination) {
                    return false
                }
            }
        }
        return true
    }
}

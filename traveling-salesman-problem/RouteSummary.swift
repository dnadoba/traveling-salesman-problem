//
//  RouteSummary.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 13/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit

class RouteSummary {
    let routes: [Route]
    lazy var waypoints: [Waypoint] = {
        guard let start = self.routes.first?.source else {
            return []
        }
        var waypoints = self.routes.map{ $0.source }
        waypoints.append(start)
        return waypoints
    }()
    
    /// summed expected travel time of all routes
    lazy var expectedTravelTime: TimeInterval = {
        return self.routes.reduce(0) { $0 + $1.expectedTravelTime }
    }()
    
    /// summed distance of all routes
    lazy var distance: CLLocationDistance = {
        return self.routes.reduce(0) { $0 + $1.distance }
    }()
    
    init(routes: [Route]) {
        self.routes = routes
    }
    
    func routeSteps(for depatureTime: Date, transferTime: TimeInterval) -> [RouteStep] {
        var nextDepatureTime = depatureTime
        let steps = routes.map { (route) -> RouteStep in
            let step = RouteStep(route: route, depatureTime: nextDepatureTime)
            nextDepatureTime = step.arrivalTime.addingTimeInterval(transferTime)
            return step
        }
        return steps
    }
    func expectedArivalTime(for depatureTime: Date) -> Date {
        return depatureTime.addingTimeInterval(expectedTravelTime)
    }
}

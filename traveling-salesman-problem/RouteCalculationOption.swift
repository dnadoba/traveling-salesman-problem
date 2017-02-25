//
//  RouteCalculationOption.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 17/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

enum RouteCalculationAlgorithm: Int {
    case automatic = 0
    case exact
    case nearestNeighbor
    
    static var all: [RouteCalculationAlgorithm] {
        return [.automatic, .exact, .nearestNeighbor]
    }
    
    func getPathAlgorithm(for manager: WaypointManager) -> PathAlgorithm {
        switch self {
        case .automatic:
            if manager.waypoints.count <= 5 {
                return .exact
            } else if manager.routeCount <= 60 {
                return .exact
            } else {
                return .nearestNeighbor
            }
        case .exact: return .exact
        case .nearestNeighbor: return .nearestNeighbor
        }
    }
}

extension RouteCalculationAlgorithm: CustomStringConvertible {
    var description: String {
        switch self {
        case .automatic: return "Automatic"
        case .exact: return "Exact (may take very long)"
        case .nearestNeighbor: return "Nearest Neighbor"
        }
    }
}

//
//  WaypointManagerState.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 20/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

enum WaypointManagerState {
    case configurating
    case calculatingRoutes(RoutesCaluclationState)
    case calculatingBestPath
    case calculatedBestPath([Route])
}

extension WaypointManagerState: Equatable {
    static func ==(lhs: WaypointManagerState, rhs: WaypointManagerState) -> Bool {
        switch (lhs, rhs) {
        case (.configurating, .configurating): return true
        case (.calculatingRoutes(let lhsState), .calculatingRoutes(let rhsState)): return lhsState == rhsState
        case (.calculatingBestPath, .calculatingBestPath): return true
        case (.calculatedBestPath(let lhsPath), .calculatedBestPath(let rhsPath)): return lhsPath == rhsPath
        default: return false
        }
    }
}

extension WaypointManagerState {
    var description: String{
        switch self {
        case .configurating: return "add 2 or more placemarks"
        case .calculatingRoutes(let routesCalculatingState): return routesCalculatingState.description
        case .calculatingBestPath: return "calculating best path"
        case .calculatedBestPath(_): return "calculated best path"
        }
    }
    var shortDescription: String {
        switch self {
        case .configurating: return "add more placemarks"
        case .calculatingRoutes(let routesCalculatingState): return routesCalculatingState.shortDescription
        case .calculatingBestPath: return "calculating..."
        case .calculatedBestPath(_): return "done ✅"
        }
    }
}

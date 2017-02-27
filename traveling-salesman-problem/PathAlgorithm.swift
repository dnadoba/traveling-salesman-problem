//
//  RouteCalculationAlgorithm.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 17/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

enum PathAlgorithm {
    case exact
    case nearestNeighbor
}

extension WeightedGraph {
    func calculatePath(from start: V, byUsing algorithm: PathAlgorithm) -> (W, [V], [E])? {
        switch algorithm {
        case .exact:
            return shortestPath(from: start)
        case .nearestNeighbor:
            return nearestNeighbarPath(from: start)
        }
    }
}

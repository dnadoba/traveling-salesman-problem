//
//  WeightedGraph-dijkstaAlgorithm.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 26.10.17.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

extension WeightedGraph {
    
    func dijkstaShortestPath(from start: V, to end: V) -> (W, [V], [E])? {
        guard contains(start) else {
            return nil
        }
        guard contains(end) else {
            return nil
        }
        
        var distanceFromStart = Dictionary<V, W>(minimumCapacity: vertexCount)
        var predecessor = Dictionary<V, V>()
        vertices.forEach { distanceFromStart[$0] = W.infinity }
        distanceFromStart[start] = W.zero;
        
        var verteciesToVisit = vertices
        
        func updateDistance(startVertex: V, neighbor: V) {
            let distanceBettwenStartAndNeighbor = edges(from: startVertex, to: neighbor).min(by: <)!.weight
            let newDistanceFromStartToNeighbor = distanceFromStart[startVertex]! + distanceBettwenStartAndNeighbor
            if newDistanceFromStartToNeighbor < distanceFromStart[neighbor]! {
                distanceFromStart[neighbor] = newDistanceFromStartToNeighbor
                predecessor[neighbor] = startVertex
            }
            
        }
        
        while !verteciesToVisit.isEmpty {
            let startVertex = verteciesToVisit.min(by: { (lhs, rhs) -> Bool in
                return distanceFromStart[lhs]! < distanceFromStart[rhs]!
            })!
            verteciesToVisit.remove(startVertex)
            let neighbors = self.neighbors(of: startVertex)
            neighbors
                .filter(verteciesToVisit.contains)
                .forEach({ (neighbor) in
                    updateDistance(startVertex: startVertex, neighbor: neighbor)
                })
            
        }
        
        
        
        
        return nil
    }
}

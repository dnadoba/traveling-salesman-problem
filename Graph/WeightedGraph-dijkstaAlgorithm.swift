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
        guard start != end else {
            return nil
        }
        guard contains(start) else {
            return nil
        }
        guard contains(end) else {
            return nil
        }
        
        var distanceFromStartTo = Dictionary<V, W>(minimumCapacity: vertexCount)
        var predecessorOf = Dictionary<V, V>()
        var predecessorEdgeOf = Dictionary<V, E>()
        vertices.forEach { distanceFromStartTo[$0] = W.infinity }
        distanceFromStartTo[start] = W.zero;
        
        var verteciesToVisit = vertices
        
        func updateDistance(startVertex: V, neighbor: V) {
            let predecessorEdgeOfNeighbor = self.edges(from: startVertex, to: neighbor).min(by: <)!
            let distanceBettwenStartAndNeighbor = predecessorEdgeOfNeighbor.weight
            let newDistanceFromStartToNeighbor = distanceFromStartTo[startVertex]! + distanceBettwenStartAndNeighbor
            if newDistanceFromStartToNeighbor < distanceFromStartTo[neighbor]! {
                distanceFromStartTo[neighbor] = newDistanceFromStartToNeighbor
                predecessorOf[neighbor] = startVertex
                predecessorEdgeOf[neighbor] = predecessorEdgeOfNeighbor
            }
            
        }
        
        while !verteciesToVisit.isEmpty {
            let startVertex = verteciesToVisit.min(by: { (lhs, rhs) -> Bool in
                return distanceFromStartTo[lhs]! < distanceFromStartTo[rhs]!
            })!
            verteciesToVisit.remove(startVertex)
            let neighbors = self.neighbors(of: startVertex)
            neighbors
                .filter(verteciesToVisit.contains)
                .forEach({ (neighbor) in
                    updateDistance(startVertex: startVertex, neighbor: neighbor)
                })
            
        }
        
        let distance = distanceFromStartTo[end]!
        //path in reversed order
        var reversedPath = [end]
        while reversedPath.last! != start {
            guard let predecessor = predecessorOf[reversedPath.last!] else {
                // a path from start to end does not exists
                return nil
            }
            reversedPath.append(predecessor)
        }
        
        let vertecies = reversedPath.reversed()
        let edges = vertecies.compactMap { predecessorEdgeOf[$0] }
        
        
        return (distance, Array(vertecies), edges)
    }
}

//
//  WeightedGraph+nearestNeighborPath.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 17/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

extension WeightedGraph {
    func nearestNeighbarPath(from start: V) -> (W, [V], [E])? {
        guard contains(start) else {
            return nil
        }
        let requiredPathLength = vertexCount
        guard requiredPathLength >= 2 else {
            return nil
        }
        return nearestNeighbarPath(start: start, path: [start], edges: [], requiredPathLength: requiredPathLength, summedWeight: W.zero)
    }
    private func nearestNeighbarPath(start: V, path: [V], edges: [E], requiredPathLength: Int, summedWeight: W) -> (W, [V], [E])? {
        guard path.count <= requiredPathLength else {
            //path is complet
            return (summedWeight, path, edges)
        }
        
        let currentVertex = path.last!
        let nextEdges = self.edges(from: currentVertex)
        
        let possibleEdges = { () -> [E] in
            
            guard path.count < requiredPathLength else {
                //we visited all nodes and have to return to the start vertex
                return nextEdges.filter {
                    return $0.destination == start
                }
            }
            
            return nextEdges.filter {
                //remove all edges which destinations are already visted nodes
                return !path.contains($0.destination)
            }
        }()
        
        //take the shortest edge
        guard let shortesEdge = possibleEdges.min() else {
            return nil
        }
        
        let nearestVertex = shortesEdge.destination
        
        var newPath = path
        newPath.append(nearestVertex)
        var newEdges = edges
        newEdges.append(shortesEdge)
        let newSummedWeight = summedWeight + shortesEdge.weight
        
        return nearestNeighbarPath(start: start, path: newPath, edges: newEdges, requiredPathLength: requiredPathLength, summedWeight: newSummedWeight)
    }
}

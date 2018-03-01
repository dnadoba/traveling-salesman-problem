//
//  WeightedGraph+shortestPath.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 09/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

extension WeightedGraph {
    
    /// finds the shortes path which visits all vertices and starts and returns to the given start vertex
    ///
    /// - Parameter start: start and end vertex
    /// - Returns: summed weight, all visited vertices in the correct order and all edges in the correct order
    func shortestPath(from start: V) -> (W, [V], [E])? {
        guard contains(start) else {
            return nil
        }
        let requiredPathLength = vertexCount
        guard requiredPathLength >= 2 else {
            return nil
        }
        let nextEdges = edges(from: start)
        let (complexity, result) = shortesPath(start: start, path: [start], edges: [], nextEdges: nextEdges, requiredPathLength: requiredPathLength, weightSummed: W.zero, complexity: 0)
        print("calculated shortest path on \(self) with complexity: \(complexity)")
        return result
    }
    private func shortesPath(start: V, path: [V], edges: [E], nextEdges: Set<E>, requiredPathLength: Int, weightSummed: W, complexity: Int) -> (Int, (W, [V], [E])?) {
        let newComplexity = complexity + 1
        //path is not posible
        if path.count == requiredPathLength {
            //route not possible
            guard let edgeToStart = nextEdges.first(where: { $0.destination == start }) else {
                return (newComplexity, nil)
            }
            
            var newPath = path
            newPath.append(start)
            var newEdges = edges
            newEdges.append(edgeToStart)
            let newWeight = weightSummed + edgeToStart.weight
            return (newComplexity, (newWeight, newPath, newEdges))
        }
        //only try edges with destination which we did not already visit
        let posibleEdges = nextEdges.filter { (nextEdge: E) -> Bool in
            return !path.contains { $0 == nextEdge.destination }
        }
        
        
        let results = posibleEdges.map { (edge) -> (Int, (W, [V], [E])?) in
            let nextVertex = edge.destination
            var newPath = path
            newPath.append(nextVertex)
            var newEdges = edges
            newEdges.append(edge)
            let nextEdges = self.edges(from: nextVertex)
            let newWeight = weightSummed + edge.weight
            
            return shortesPath(start: start, path: newPath, edges: newEdges, nextEdges: nextEdges, requiredPathLength: requiredPathLength, weightSummed: newWeight, complexity: 0)
        }
        let summedComplexity = results.map({$0.0}).reduce(newComplexity, +)
        let possiblePaths = results.compactMap({$0.1})
        
        return (summedComplexity, possiblePaths.min{$0.0 < $1.0})
    }
}

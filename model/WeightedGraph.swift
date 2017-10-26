//
//  WeightedGraph.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 09/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

/// A weighted graph struct that can hold any Vertex that conforms to the Vertex protocol.
/// Edges must conform to the `WeightedEdge` protocol and can be used to connect two vertices.
struct WeightedGraph<V, E: WeightedEdge> where V == E.V {
    typealias W = E.Weight
    private(set) var vertices: Set<V> = []
    private var edgesStartingFromVertex: [V: Set<E>] = [:]
    
    /// The number of vertices in the graph
    var vertexCount: Int {
        return vertices.count
    }
    
    /// The number of edges in the graph
    var edgeCount: Int {
        return edgesStartingFromVertex.values.reduce(0) { $0 + $1.count }
    }
    
    /// A set containing all edges of the grpah
    var edges: Set<E> {
        return edgesStartingFromVertex.values.reduce(Set<E>()) { (allEdges, otherEdges) -> Set<E> in
            return allEdges.union(otherEdges)
        }
    }
    // MARK: Vertex methods
    
    /// Returns a Boolean value that indicates whether the given vertex exists in the set.
    ///
    /// - Parameter vertex: A vertex to look for in the graph
    /// - Returns: true if the vertex is in the graph, otherwise false
    func contains(_ vertex: V) -> Bool {
        return vertices.contains(vertex)
    }
    
    /// Inserts the given vertex in the graph if it is not already present.
    ///
    /// - Parameter vertex: Vertex to insert into the graph
    /// - Returns: true it the vertex was not already in the graph, otherwise false
    @discardableResult
    mutating func insertVertex(_ vertex: V) -> Bool {
        let (inserted, _) = vertices.insert(vertex)
        if inserted {
            edgesStartingFromVertex[vertex] = []
        }
        return inserted
    }
    
    /// Removes the given vertex and any edge that has the given vertex as its source or destinaion
    ///
    /// - Parameter vertex: Vertex to remove from the graph
    mutating func remove(_ vertex: V) {
        removeAllEdgesFromAndTo(vertex)
        vertices.remove(vertex)
    }
    // MARK: edge methods
    
    /// Insertes a given edge into the graph if the source and destionation vertex are in the graph and the edge is not already in the graph
    ///
    /// - Parameter edge: Edge to insert into the graph
    /// - Returns: true if the source and destionation vertex are in the graph and the edge is not already in the graph, otherwise false
    @discardableResult
    mutating func insertEdge(_ edge: E) -> Bool {
        guard vertices.contains(edge.source) && vertices.contains(edge.destination) else {
            return false
        }
        let (inserted, _) = edgesStartingFromVertex[edge.source]!.insert(edge)
        return inserted
    }
    
    /// Removes the given edge if it exists in the graph
    ///
    /// - Parameter edge: edge to remove from the graph
    /// - Returns: true if the edge was in the graph and was removed, otherwise false
    @discardableResult
    mutating func remove(_ edge: E) -> Bool {
        return edgesStartingFromVertex[edge.source]?.remove(edge) != nil
    }
    
    /// Removes all edges
    ///
    /// - Parameter keepingCapacity: if true, the graph's storage for the edges is preserved
    mutating func removeAllEdges(keepingCapacity: Bool = false) {
        for vertex in edgesStartingFromVertex.keys {
            edgesStartingFromVertex[vertex]!.removeAll(keepingCapacity: keepingCapacity)
        }
    }
    
    /// Removes all edges starting from and ending at the given vertex
    ///
    /// - Parameter vertex: The vertex to remove all edges starting
    mutating func removeAllEdgesFromAndTo(_ vertex: V) {
        removeEdges(from: vertex)
        removeEdges(to: vertex)
    }
    
    /// Remove all edges starting from a given vertex
    ///
    /// - Parameter vertex: The vertex to remove all edges starting at itself
    mutating func removeEdges(from vertex: V) {
        edgesStartingFromVertex[vertex]?.removeAll()
        
    }
    
    /// Removes all edges ending at a given vertex
    ///
    /// - Parameter vertex: The vertex to remove all edges ending at itself
    mutating func removeEdges(to vertex: V) {
        guard contains(vertex) else {
            return
        }
        
        for (sourceVertex, edgesStartingFromOtherVertices) in edgesStartingFromVertex {
            let edgesWithDestinationToVertex = edgesStartingFromOtherVertices.filter {
                return $0.destination == vertex
            }
            edgesStartingFromVertex[sourceVertex]!.subtract(edgesWithDestinationToVertex)
        }
    }
    
    
    /// Returns set containg only the edges starting from a given vertx or an empty set if the vertex is not in the graph
    ///
    /// - Parameter vertex: The vertex the edges must start from
    /// - Returns: a set containg only edges starting from a given vertx
    func edges(from vertex: V) -> Set<E> {
        return edgesStartingFromVertex[vertex] ?? []
    }
    
    /// Returns set containg only the edges ending at a given vertx or an empty set if the vertex is not in the graph
    ///
    /// - Parameter vertex: The vertex the edges must end at
    /// - Returns: a set containg only edges ending at a given vertx
    func edges(to vertex: V) -> Set<E> {
        guard contains(vertex) else {
            return []
        }
        var edgesWithDestinationToVertex = Set<E>()
        for (_, edgesStartingFromOtherVertices) in edgesStartingFromVertex {
            let edges = edgesStartingFromOtherVertices.filter {
                return $0.destination == vertex
            }
            edgesWithDestinationToVertex.formUnion(edges)
        }
        return edgesWithDestinationToVertex
    }
    
    /// Returns a boolean value that indicates weahter a edge with a given source and given destination vertex exists or not
    ///
    /// - Parameters:
    ///   - source: The vertex the edge should start
    ///   - destination: The vertex the edge should start
    /// - Returns: true if such an edge exits, otherwise false
    func containsEdge(from source: V, to destination: V) -> Bool {
        let edgesStartingFromSource = edgesStartingFromVertex[source]
        return edgesStartingFromSource?.contains { $0.destination == destination } ?? false
    }
    
}

extension WeightedGraph {
    func neighbors(of vertex: V) -> [V] {
        return edges(from: vertex).map { $0.destination }
    }
}

extension WeightedGraph {
    func edges(from start: V, to end: V) -> [E] {
        return edges(from: start).filter { $0.destination == end }
    }
}


// MARK: - CustomDebugStringConvertible
extension WeightedGraph: CustomDebugStringConvertible {
    var debugDescription: String {
        return "WeightedGraph(vertexCount: \(vertexCount), edgeCount: \(edgeCount))"
    }
}

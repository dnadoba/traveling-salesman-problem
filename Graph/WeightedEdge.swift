//
//  WeightedEdge.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 09/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation


/// A Type that can be used to connect two Vertices of the same Type.
/// The Edge is weighted.
protocol WeightedEdge: Comparable, Hashable {
    associatedtype Weight: EdgeWeight
    associatedtype V: Vertex
    
    var source: V { get }
    var destination: V { get }
    var weight: Weight { get }
}

protocol EdgeWeight: Comparable {
    static var infinity: Self { get }
    static var zero: Self { get }
    static func +(lhs: Self, rhs: Self) -> Self
}

// MARK: - Equatable
extension WeightedEdge {
    static func ==(lhs: Self, rhs: Self) -> Bool { return lhs.weight == rhs.weight }
    static func !=(lhs: Self, rhs: Self) -> Bool { return lhs.weight != rhs.weight }
}

// MARK: - Comparable
extension WeightedEdge {
    static func <(lhs: Self, rhs: Self) -> Bool { return lhs.weight < rhs.weight }
    static func >(lhs: Self, rhs: Self) -> Bool { return lhs.weight > rhs.weight }
    static func <=(lhs: Self, rhs: Self) -> Bool { return lhs.weight <= rhs.weight }
    static func >=(lhs: Self, rhs: Self) -> Bool { return lhs.weight >= rhs.weight }
}

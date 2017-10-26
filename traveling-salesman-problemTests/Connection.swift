//
//  Connection.swift
//  traveling-salesman-problemTests
//
//  Created by David Nadoba on 26.10.17.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
@testable import traveling_salesman_problem

struct Connection {
    static let oneWayConnection = [
        Connection(source: .limburgerhof, destination: .ludwigshafen, distance: 5),
        Connection(source: .limburgerhof, destination: .mannheim, distance: 7),
        Connection(source: .limburgerhof, destination: .berlin, distance: 600),
        Connection(source: .limburgerhof, destination: .frankfurt, distance: 80),
        Connection(source: .limburgerhof, destination: .hamburg, distance: 400),
        Connection(source: .limburgerhof, destination: .muenchen, distance: 300),
        Connection(source: .ludwigshafen, destination: .mannheim, distance: 2),
        Connection(source: .ludwigshafen, destination: .berlin, distance: 550),
        Connection(source: .ludwigshafen, destination: .frankfurt, distance: 70),
        Connection(source: .ludwigshafen, destination: .hamburg, distance: 380),
        Connection(source: .ludwigshafen, destination: .muenchen, distance: 280),
        Connection(source: .mannheim, destination: .berlin, distance: 500),
        Connection(source: .mannheim, destination: .frankfurt, distance: 60),
        Connection(source: .mannheim, destination: .hamburg, distance: 350),
        Connection(source: .mannheim, destination: .muenchen, distance: 250),
        Connection(source: .berlin, destination: .frankfurt, distance: 400),
        Connection(source: .berlin, destination: .hamburg, distance: 150),
        Connection(source: .berlin, destination: .muenchen, distance: 900),
        Connection(source: .frankfurt, destination: .hamburg, distance: 280),
        Connection(source: .frankfurt, destination: .muenchen, distance: 320),
        Connection(source: .hamburg, destination: .muenchen, distance: 700),
        ]
    static let allConnections = oneWayConnection + oneWayConnection.map { $0.reversed() }
    
    var source: Station
    var destination: Station
    var distance: Double
    
}
extension Connection {
    
    /// Creates a new reversed `Connection` from `desintation` to `source` with the same weight
    ///
    /// - Returns: a reversed connection with the same weight
    func reversed() -> Connection {
        var copy = self
        copy.source = self.destination
        copy.destination = self.source
        return copy
    }
}
extension Connection: Equatable {
    static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return lhs.source == rhs.source &&
            lhs.source == rhs.source &&
            lhs.distance == rhs.distance
    }
    static func !=(lhs: Connection, rhs: Connection) -> Bool {
        return lhs.source != rhs.source ||
            lhs.source != rhs.source ||
            lhs.distance != rhs.distance
    }
}
extension Connection: Hashable {
    var hashValue: Int { return source.hashValue ^ destination.hashValue ^ distance.hashValue }
}

extension Connection: WeightedEdge {
    var weight: Double { return distance }
}

func makeGraphWithAllStationsAndAllConnections() -> WeightedGraph<Station, Connection> {
    var graph = makeGraphWithAllStations()
    //insert all connections
    for connection in Connection.allConnections {
        graph.insertEdge(connection)
    }
    return graph
}

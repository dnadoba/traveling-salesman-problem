//
//  Station.swift
//  traveling-salesman-problemTests
//
//  Created by David Nadoba on 26.10.17.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
@testable import traveling_salesman_problem

struct Station {
    static let limburgerhof = Station(name: "Limburgerhof")
    static let ludwigshafen = Station(name: "Ludwigshafen")
    static let mannheim = Station(name: "Mannheim")
    static let berlin = Station(name: "Berlin")
    static let frankfurt = Station(name: "Frankfurt")
    static let hamburg = Station(name: "Hamburg")
    static let muenchen = Station(name: "München")
    
    static let allStations: [Station] = [
        .limburgerhof,
        .ludwigshafen,
        .mannheim,
        .berlin,
        .frankfurt,
        .hamburg,
        .muenchen,
    ]
    
    var name: String
}
extension Station: Equatable {
    static func ==(lhs: Station, rhs: Station) -> Bool { return lhs.name == rhs.name }
    static func !=(lhs: Station, rhs: Station) -> Bool { return lhs.name != rhs.name }
}
extension Station: Hashable {
    var hashValue: Int { return name.hashValue }
}
extension Station: Vertex {}


func makeGraphWithAllStations() -> WeightedGraph<Station, Connection> {
    var graph = WeightedGraph<Station, Connection>()
    //insert all stations
    for station in Station.allStations {
        graph.insertVertex(station)
    }
    return graph
}

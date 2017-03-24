//
//  swift
//  traveling-salesman-problemTests
//
//  Created by David Nadoba on 06/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import XCTest
@testable import traveling_salesman_problem

struct Station {
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

struct Connection {
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

let limburgerhof = Station(name: "Limburgerhof")
let ludwigshafen = Station(name: "Ludwigshafen")
let mannheim = Station(name: "Mannheim")
let berlin = Station(name: "Berlin")
let frankfurt = Station(name: "Frankfurt")
let hamburg = Station(name: "Hamburg")
let muenchen = Station(name: "München")

let stations = [
    limburgerhof,
    ludwigshafen,
    mannheim,
    berlin,
    frankfurt,
    hamburg,
    muenchen,
]

func makeGraphWithAllStations() -> WeightedGraph<Station, Connection> {
    var graph = WeightedGraph<Station, Connection>()
    //insert all stations
    for station in stations {
        graph.insertVertex(station)
    }
    return graph
}
let graphWithAllStatoins = makeGraphWithAllStations()

let oneWayConnection = [
    Connection(source: limburgerhof, destination: ludwigshafen, distance: 5),
    Connection(source: limburgerhof, destination: mannheim, distance: 7),
    Connection(source: limburgerhof, destination: berlin, distance: 600),
    Connection(source: limburgerhof, destination: frankfurt, distance: 80),
    Connection(source: limburgerhof, destination: hamburg, distance: 400),
    Connection(source: limburgerhof, destination: muenchen, distance: 300),
    Connection(source: ludwigshafen, destination: mannheim, distance: 2),
    Connection(source: ludwigshafen, destination: berlin, distance: 550),
    Connection(source: ludwigshafen, destination: frankfurt, distance: 70),
    Connection(source: ludwigshafen, destination: hamburg, distance: 380),
    Connection(source: ludwigshafen, destination: muenchen, distance: 280),
    Connection(source: mannheim, destination: berlin, distance: 500),
    Connection(source: mannheim, destination: frankfurt, distance: 60),
    Connection(source: mannheim, destination: hamburg, distance: 350),
    Connection(source: mannheim, destination: muenchen, distance: 250),
    Connection(source: berlin, destination: frankfurt, distance: 400),
    Connection(source: berlin, destination: hamburg, distance: 150),
    Connection(source: berlin, destination: muenchen, distance: 900),
    Connection(source: frankfurt, destination: hamburg, distance: 280),
    Connection(source: frankfurt, destination: muenchen, distance: 320),
    Connection(source: hamburg, destination: muenchen, distance: 700),
]
let connections = oneWayConnection + oneWayConnection.map { $0.reversed() }

func makeGraphWithAllStationsAndAllConnections() -> WeightedGraph<Station, Connection> {
    var graph = WeightedGraph<Station, Connection>()
    //insert all stations
    for station in stations {
        graph.insertVertex(station)
    }
    //insert all connections
    for connection in connections {
        graph.insertEdge(connection)
    }
    return graph
}
let graphWithAllStationsAnsAllConnections = makeGraphWithAllStationsAndAllConnections()

class traveling_salesman_problemTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInsertVertices() {
        var graph = WeightedGraph<Station, Connection>()
        var insertCount = 0
        //insert all stations
        for station in stations {
            graph.insertVertex(station)
            insertCount += 1
            XCTAssertEqual(graph.vertexCount, insertCount)
            XCTAssertTrue(graph.contains(station))
        }
    }
    func testRemoveVertices() {
        var graph = graphWithAllStatoins
        //remove all stations
        var stationCount = graph.vertexCount
        for station in stations {
            graph.remove(station)
            stationCount -= 1
            XCTAssertEqual(graph.vertexCount, stationCount)
            XCTAssertFalse(graph.contains(station))
        }
    }
    func testInsertEdges() {
        var graph = graphWithAllStatoins
        
        var connectionCount = 0
        //insert all connections
        for connection in connections {
            graph.insertEdge(connection)
            connectionCount += 1
            XCTAssertEqual(graph.edgeCount, connectionCount)
            XCTAssertTrue(graph.containsEdge(from: connection.source, to: connection.destination))
        }
    }
    func testRemoveEdges() {
        var graph = graphWithAllStationsAnsAllConnections
        
        var connectionCount = graph.edgeCount
        //remove all connections
        for connection in connections {
            graph.remove(connection)
            connectionCount -= 1
            XCTAssertEqual(graph.edgeCount, connectionCount)
            XCTAssertFalse(graph.containsEdge(from: connection.source, to: connection.destination))
        }
    }
    func testCalculateShortestPath() {
        let graph = graphWithAllStationsAnsAllConnections
        let path = graph.shortestPath(from: limburgerhof)
        
        XCTAssertNotNil(path)
        if let path = path {
            let shortestPathShouldBe =  [
                limburgerhof,
                mannheim,
                hamburg,
                berlin,
                frankfurt,
                muenchen,
                ludwigshafen,
                limburgerhof,
            ]
            XCTAssertEqual(path.1, shortestPathShouldBe)
        }
    }
    
}

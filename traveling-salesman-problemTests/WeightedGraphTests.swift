//
//  swift
//  traveling-salesman-problemTests
//
//  Created by David Nadoba on 06/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import XCTest
@testable import traveling_salesman_problem

let graphWithAllStatoins = makeGraphWithAllStations()

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
        for station in Station.allStations {
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
        for station in Station.allStations {
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
        for connection in Connection.allConnections {
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
        for connection in Connection.allConnections {
            graph.remove(connection)
            connectionCount -= 1
            XCTAssertEqual(graph.edgeCount, connectionCount)
            XCTAssertFalse(graph.containsEdge(from: connection.source, to: connection.destination))
        }
    }
    func testCalculateShortestPath() {
        let graph = graphWithAllStationsAnsAllConnections
        let path = graph.shortestPath(from: .limburgerhof)
        
        XCTAssertNotNil(path)
        if let path = path {
            let shortestPathShouldBe: [Station] =  [
                .limburgerhof,
                .mannheim,
                .hamburg,
                .berlin,
                .frankfurt,
                .muenchen,
                .ludwigshafen,
                .limburgerhof,
            ]
            XCTAssertEqual(path.1, shortestPathShouldBe)
        }
    }
    
}

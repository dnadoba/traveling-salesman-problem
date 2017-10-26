//
//  DijkstraAlgorithmTest.swift
//  traveling-salesman-problemTests
//
//  Created by David Nadoba on 27.10.17.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import XCTest
@testable import traveling_salesman_problem

class DijkstraAlgorithmTest: XCTestCase {

    func testExample() {
        let graph = makeGraphWithAllStationsAndAllConnections()
        let result = graph.dijkstaShortestPath(from: .limburgerhof, to: .berlin)
        XCTAssertNotNil(result)
        guard let r = result else {
            return
        }
        let (distance, vertecies, edges) = r
        print(distance)
        print(vertecies)
        print(edges)
    }

}

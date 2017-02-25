//
//  RouteStepCellView.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 14/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Cocoa

class RouteStepCellView: NSTableCellView {

    @IBOutlet weak var depatureTime: NSTextField!
    @IBOutlet weak var source: NSTextField!
    @IBOutlet weak var arivalTime: NSTextField!
    @IBOutlet weak var destination: NSTextField!
    
    var routeStep: RouteStep? {
        didSet{
            updateRouteStep()
        }
    }
    
    private func updateRouteStep() {
        depatureTime.objectValue = routeStep?.depatureTime
        source.stringValue = routeStep?.source.title ?? ""
        arivalTime.objectValue = routeStep?.arrivalTime
        destination.stringValue = routeStep?.destination.title ?? ""
    }
    
}

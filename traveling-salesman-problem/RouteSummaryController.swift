//
//  RouteSummaryController.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 13/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Cocoa

private let routeStepCellIdentifier = "RouteStepCell"

class RouteSummaryController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var depatureTimePicker: NSDatePicker!
    @IBOutlet weak var distance: NSTextField!
    @IBOutlet weak var expectedTravelTime: NSTextField!
    @IBOutlet weak var expectedArivalTime: NSTextFieldCell!
    var routeSummary: RouteSummary? {
        didSet {
            updateRouteSummary()
        }
    }
    
    var routeSteps: [RouteStep] = []
    var useCurrentTimeAsDepatureTime = true
    var depatureTime = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateRouteSummary()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private let expectedTravelTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .hour, .day]
        return formatter
    }()
    
    private func updateRouteSummary() {
        if useCurrentTimeAsDepatureTime {
            depatureTime = Date()
        }
        depatureTimePicker.objectValue = depatureTime
        distance.doubleValue = routeSummary?.distance ?? 0
        expectedTravelTime.stringValue = expectedTravelTimeFormatter.string(from: routeSummary?.expectedTravelTime ?? 0) ?? "--"
        if let routeSummary = routeSummary {
            expectedArivalTime.objectValue = routeSummary.expectedArivalTime(for: depatureTime)
        } else {
            expectedArivalTime.stringValue = "--"
        }
        routeSteps = routeSummary?.routeSteps(for: depatureTime, transferTime: 0) ?? []
        tableView.reloadData()
    }
    @IBAction func userDidChangeDepatureTime(_ sender: NSDatePicker) {
        useCurrentTimeAsDepatureTime = false
        depatureTime = sender.dateValue
        updateRouteSummary()
    }
    @IBAction func useCurrentTimeAsDepauterTime(_ sender: NSButton) {
        useCurrentTimeAsDepatureTime = true
        updateRouteSummary()
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return routeSteps.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let routeStep = routeSteps[safe: row] else {
            return nil
        }
        guard let routeStepView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: routeStepCellIdentifier), owner: nil) as? RouteStepCellView else {
            return nil
        }
        routeStepView.routeStep = routeStep
        return routeStepView
    }
}

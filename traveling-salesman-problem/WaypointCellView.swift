//
//  WaypointCellView.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 17/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Cocoa

protocol WaypointCellViewDelegate: class {
    func setAsStartWaypoint(_ cell: WaypointCellView, waypoint: Waypoint)
}

class WaypointCellView: NSTableCellView {
    weak var delegate: WaypointCellViewDelegate?
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var startWaypointButton: NSButton!
    var waypoint: Waypoint? {
        didSet {
            update()
        }
    }
    
    var isStartWaypoint: Bool = false {
        didSet {
            guard oldValue != isStartWaypoint else { return }
            update()
        }
    }
    
    func update() {
        nameLabel.stringValue = waypoint?.title ?? ""
        startWaypointButton.isHidden = isStartWaypoint
    }
    @IBAction func setAsStartWaypoint(_ sender: NSButton) {
        
        waypoint.then {
            delegate?.setAsStartWaypoint(self, waypoint: $0)
        }
    }
}

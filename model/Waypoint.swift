//
//  Waypoint.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 07/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit



/// A Waypoint is used to describe a location on a map
class Waypoint: NSObject {
    
    /// 2D location coordinates of the waypoint
    let location: CLLocationCoordinate2D
    
    /// optional placemark which contains information like the name of the given location
    var placemark: MKPlacemark?
    var name: String {
        return placemark?.title ?? location.formatted
    }
    init(location: CLLocationCoordinate2D) {
        self.location = location
    }
}

// MARK: - MKAnnotation
extension Waypoint: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return location
    }
    var title: String? {
        return name
    }
    var subtitle: String? {
        return nil
    }
}

// MARK: - Mapitem
extension Waypoint {
    var mapitem: MKMapItem {
        return MKMapItem(placemark: placemark ?? MKPlacemark(coordinate: location))
    }
}
// MARK: - Description
extension Waypoint {
    override var description: String {
        return "Waypoint(\(name))"
    }
}

// MARK: - Vertex
extension Waypoint: Vertex {}

//
//  CLLocationCoordinate2D+extension.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 08/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    var formatted: String {
        return "latitude: \(latitude) longitude: \(longitude)"
    }
}

//
//  MKMapView+extension.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 13/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func setVisibleMapRects(_ mapRects: [MKMapRect], animated: Bool) {
        setVisibleMapRects(mapRects, edgePadding: .init(), animated: animated)
    }
    func setVisibleMapRects(_ mapRects: [MKMapRect], edgePadding: NSEdgeInsets, animated: Bool) {
        if let firstMapRect = mapRects.first {
            let unionMapRect = mapRects.dropFirst().reduce(firstMapRect, MKMapRectUnion)
            setVisibleMapRect(unionMapRect, edgePadding: edgePadding, animated: animated)
        }
    }
}

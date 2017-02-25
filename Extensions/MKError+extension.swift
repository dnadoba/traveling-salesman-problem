//
//  MKError+extension.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 09/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit

extension MKError {
    var throttleStateResetTimeRemaining: TimeInterval? {
        guard code == MKError.loadingThrottled,
            let errorDict = errorUserInfo["MKErrorGEOErrorUserInfo"] as? [String: Any],
            let duration = (errorDict["GEORequestThrottleStateResetTimeRemaining"] as? NSNumber)?.doubleValue else {
                return nil
        }
        return duration
    }
}

//
//  RouteCalculationState.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 20/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

struct RoutesCaluclationState {
    enum ThrottleState {
        case none
        case until(Date)
    }
    var queued: Int
    var throtteled = ThrottleState.none
    
    var description: String {
        switch throtteled {
        case .none: return "calculating \(queued + 1) routes"
        case .until(let thortteledUntil):
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            return "calculating \(queued + 1) routes but throtteled for \(formatter.string(from: Date(), to: thortteledUntil) ?? "")"
        }
    }
    var shortDescription: String {
        switch throtteled {
        case .none: return "calculating \(queued + 1) routes"
        case .until(let thortteledUntil):
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            return "throtteled for \(formatter.string(from: Date(), to: thortteledUntil) ?? "")"
        }
    }
}

extension RoutesCaluclationState.ThrottleState: Equatable {
    static func ==(lhs: RoutesCaluclationState.ThrottleState, rhs: RoutesCaluclationState.ThrottleState) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none): return true
        case (.until(let lhsDate), .until(let rhsDate)): return lhsDate == rhsDate
        default: return false
        }
    }
}

extension RoutesCaluclationState: Equatable {
    static func ==(lhs: RoutesCaluclationState, rhs: RoutesCaluclationState) -> Bool {
        return lhs.queued == rhs.queued &&
            lhs.throtteled == rhs.throtteled
    }
}

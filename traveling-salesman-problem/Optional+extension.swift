//
//  Optional+extension.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 17/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

extension Optional {
    // `then` function executes the closure if there is some value
    func then(_ handler: (Wrapped) -> Void) {
        switch self {
        case .some(let wrapped): return handler(wrapped)
        case .none: break
        }
    }
}

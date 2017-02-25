//
//  Collection+extension.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 08/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

extension Collection {
    func isValidIndex(_ index: Index) -> Bool {
        return index >= startIndex && index < endIndex
    }
    
    /// A safe way to subscript a collection
    ///
    /// - Parameter index: index of the element
    subscript(safe index: Index) -> Iterator.Element? {
        if isValidIndex(index) {
            return self[index]
        }
        return nil
    }
}

extension Collection {
    func min(isSmaller: (Iterator.Element, Iterator.Element) -> (Bool)) -> Iterator.Element? {
        guard !isEmpty else {
            return nil
        }
        var smallesElement = first!
        for nextElement in self {
            if isSmaller(nextElement, smallesElement) {
                smallesElement = nextElement
            }
        }
        return smallesElement
    }
}

extension RangeReplaceableCollection where Iterator.Element: Equatable{
    mutating func removeFirst(_ element: Iterator.Element) {
        guard let indexToRemove = index(of: element) else {
            return
        }
        remove(at: indexToRemove)
    }
}

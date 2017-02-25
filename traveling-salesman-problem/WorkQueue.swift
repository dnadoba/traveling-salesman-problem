//
//  WorkQueue.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 09/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation

enum WorkQueueState {
    case idle
    case working
    case pausing(until: Date)
}
extension WorkQueueState: Equatable {
    static func ==(lhs: WorkQueueState, rhs: WorkQueueState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, idle): return true
        case (.working, .working): return true
        case (.pausing(let lhsDate), .pausing(let rhsDate)): return lhsDate == rhsDate
        default: return false
        }
    }
}

class WorkQueue<WorkItem> {
    typealias WorkQueueCallback = (WorkQueue<WorkItem>, WorkItem) -> ()
    typealias WorkQueueStateChangeCallback = (_ oldState: WorkQueueState, _ newState: WorkQueueState) -> ()
    
    private var items: [WorkItem] = []
    
    var count: Int {
        return items.count
    }
    
    private(set) var state = WorkQueueState.idle {
        didSet {
            guard state != oldValue else {
                return
            }
            queueStateDidChange?(oldValue, state)
        }
    }
    
    /// the queue will call this method for every item in the queue
    /// after this callback has finshed processing the item it must call finishWork(on _:)
    var workCallback: WorkQueueCallback? {
        didSet {
            update()
        }
    }
    
    var queueStateDidChange: WorkQueueStateChangeCallback?
    
    private var timer: Timer?
    
    
    /// after a worker is done working on an item it must call this method
    /// the queue will immiediatly start working on the next item
    ///
    /// - Parameter item: item that was processed
    public func finishWork(on item: WorkItem) {
        startWorkOnNextItem()
    }
    
    /// pauses the queue for a given duration and will continue working afterwards
    ///
    /// - Parameter duration: duration to pause the queue
    public func pauseWork(for duration: TimeInterval) {
        pauseWork(until: Date().addingTimeInterval(duration))
    }
    
    /// pauses the queue until the date will expire and will continue working afterwards
    ///
    /// - Parameter date: date in the future
    public func pauseWork(until date: Date) {
        self.timer?.invalidate()
        state = .pausing(until: date)
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(timerDidExpire), userInfo: nil, repeats: false)
        timer.tolerance = 1
        self.timer = timer
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
    }
    
    @objc private func timerDidExpire() {
        update()
    }
    
    /// appends an item to the end of the queue and process it immediately if the queue is idle
    ///
    /// - Parameter item: item to append to the end of the queue
    public func append(_ item: WorkItem) {
        items.append(item)
        update()
    }
    
    /// appends all items to the end of the queue and process the first immediately if the queue is idle
    ///
    /// - Parameter newItems: items to add to the end of the queue
    public func append(contentsOf newItems: [WorkItem]) {
        items.append(contentsOf: newItems)
        update()
    }
    /// appends an item to the begining of the queue and process it immediately if the queue is idle
    ///
    /// - Parameter item: item to append to the begining of the queue
    public func push(_ item: WorkItem) {
        items.insert(item, at: 0)
        update()
    }
    /// appends all item to the begining of the queue and process one immediately if the queue is idle
    ///
    /// - Parameter item: items to append to the begining of the queue
    public func push(contentsOf newItems: [WorkItem]) {
        items.insert(contentsOf: newItems, at: 0)
        update()
    }
    
    /// removes elements from the queue determined by the given closure
    ///
    /// - Parameter shouldRemove: a clousure which is called for each work item and returns a Boolean value indicating whether the element shoud be removed from the queue or not
    /// - Returns: the number of removed work items
    @discardableResult
    public func remove(_ shouldRemove: (WorkItem)-> Bool) -> Int {
        let previousItemCount = items.count
        items = items.filter{ !shouldRemove($0) }
        let removedItemsCount = previousItemCount - items.count
        return removedItemsCount
    }
    
    public func removeAll() {
        items.removeAll()
    }
    
    private func update() {
        guard workCallback != nil else {
            return
        }
        
        switch state {
        case .idle:
            startWorkOnNextItem()
        case .working:
            return
        case .pausing(let pauseDate):
            if pauseDate < Date() {
                startWorkOnNextItem()
            } else {
                pauseWork(until: pauseDate)
            }
        }
    }
    private func startWork(on item: WorkItem) {
        workCallback!(self, item)
    }
    private func startWorkOnNextItem() {
        guard let item = next() else {
            state = .idle
            return
        }
        state = .working
        startWork(on: item)
    }
    private func next() -> WorkItem? {
        return items.isEmpty ? nil : items.removeFirst()
    }
}

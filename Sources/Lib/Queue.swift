//
//  Queue.swift
//  ABM
//
//  Created by Tierry Hörmann on 12.04.17.
//
//

/// An ordinary queue
public struct Queue<T>: Sequence {
    fileprivate var first: QNode<T>?
    fileprivate var last: QNode<T>?
    public private(set) var count = 0
    public var isEmpty: Bool {
        get { return count == 0 }
    }

    public mutating func enqueue(_ val: T) {
        if isEmpty {
            first = QNode<T>(val: val, next: nil, prev: nil)
            last = first
        } else {
            let l = QNode<T>(val: val, next: last!, prev: nil)
            last!.prev = l
            last = l
        }
        count += 1
    }
	
    public mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        }
        let f = first!
        first = f.prev
        if first != nil {
            first!.next = nil
        } else {
            last = nil
        }
        count -= 1
        return f.val
    }
    
    public func makeIterator() -> QueueIterator<T> {
        return QueueIterator<T>(self)
    }
}

public struct QueueIterator<T>: IteratorProtocol {
    private var queue: Queue<T>
    public init(_ q: Queue<T>) {
        queue = q
    }
    
    public mutating func next() -> T? {
        return queue.dequeue()
    }
}

private class QNode<T> {
    let val: T
    var next: QNode<T>?
    weak var prev: QNode<T>?
    init(val: T, next: QNode<T>?, prev: QNode<T>?) {
        self.val = val
        self.next = next
    }
}

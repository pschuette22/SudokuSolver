//
//  Queue.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 4/5/22.
//

import Foundation


class Stack<T> {
    private(set) var count: Int = 0
    private var first: Node<T>?
    private weak var last: Node<T>?
    private let lock = NSLock()
    
    init(
        _ data: [T] = []
    ) {
        data.reversed().forEach { push($0) }
    }
    
    var asArray: [T] {
        var node = first
        var result = [T]()

        while let data = node?.data {
            result.append(data)
            node = node?.next
        }
        return result
    }
    
    func peek() -> T? {
        return first?.data
    }
    
    func peekLast() -> T? {
        return last?.data
    }
    
    func push(_ data: T) {
        print("locking")
        lock.lock()
        print("did lock")
        defer {
            lock.unlock()
            print("did unlock")
        }

        let node = Node(data, previous: nil, next: first)
        self.first = node
        if last.isNil {
            last = first
        }

        count += 1
    }
    
    func pop() -> T? {
        print("locking")
        lock.lock()
        print("did lock")
        defer {
            lock.unlock()
            print("did unlock")
        }
        
        let data = first?.data
        self.first = first?.next
        
        if data.isNotNil {
            count -= 1
        }
        
        return data
    }
    
    func dropLast() {
        guard last.isNotNil else { return }
        
        print("locking")
        lock.lock()
        print("did lock")
        defer {
            lock.unlock()
            print("did unlock")
        }
        
        self.last = self.last?.previous
        self.last?.removeNext()
        count -= 1
        
        #if DEBUG
        var node = self.first
        var count = 0
        while node != nil {
            count += 1
            node = node?.next
        }
        print("drop last real count: \(count)")
        #endif
    }
    
    func clear() {
        print("locking")
        lock.lock()
        print("did lock")
        defer {
            lock.unlock()
            print("did unlock")
        }

        first = nil
        last = nil
        count = 0
    }
    
    subscript(_ index: Int) -> T? {
        guard (0..<count).contains(index) else { return nil }
        
        var node = first
        for _ in 0..<index-1 {
            node = node?.next
        }
        
        return node?.data
    }
}

// MARK: - Stack+Node

private extension Stack {
    class Node<T> {
        let data: T
        weak var previous: Node<T>?
        private var wasFreed = false
        var next: Node<T>? {
            get {
                wasFreed ? nil : _next
            }

            set {
                wasFreed = newValue.isNil
                _next = newValue
            }
        }
        
        private var _next: Node<T>?
        
        init(_ data: T, previous: Node<T>? = nil, next: Node<T>? = nil) {
            self.data = data
            self.previous = previous
            self._next = next
        }
        
        func removeNext() {
            self.next = nil
        }
    }
}

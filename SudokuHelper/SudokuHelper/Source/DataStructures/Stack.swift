//
//  Queue.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 4/5/22.
//

import Foundation


struct Stack<T> {
    private(set) var count: Int = 0
    private var first: Node<T>?
    private weak var last: Node<T>?
    
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
    
    mutating
    func push(_ data: T) {
        first = Node(data, previous: nil, next: first)
        if last.isNil {
            last = first
        }
        count += 1
    }
    
    mutating
    func pop() -> T? {
        let data = first?.data
        self.first = first?.next
        
        if data.isNotNil {
            count -= 1
        }
        
        return data
    }
    
    mutating
    func dropLast() {
        guard last.isNotNil else { return }
        
        last = last?.previous
        count -= 1
    }
    
    mutating
    func clear() {
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
        var next: Node<T>?
        
        init(_ data: T, previous: Node<T>? = nil, next: Node<T>? = nil) {
            self.data = data
            self.previous = previous
            self.next = next
        }
        
        func push(_ data: T) -> Node<T> {
            if let next = next {
                return next.push(data)
            } else {
                let node = Node<T>(data)
                node.previous = self
                next = node
                return node
            }
        }
    }
}

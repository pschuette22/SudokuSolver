//
//  Array+Extensions.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/31/21.
//

import Foundation


// MARK: - Array where Element is Hashable
extension Array where Element: Hashable {
    var set: Set<Element> {
        Set(self)
    }
}

// MARK: - Array where Element is Sequence
extension Array where Element: Sequence {
    var flattened: [Element.Element] {
        self.flatMap({ $0 })
    }
}

// MARK: - Combining
extension Array {
    func appending(_ element: Element) -> [Element] {
        var result = [Element]()
        result.append(contentsOf: self)
        result.append(element)
        return result
    }

    func appending<S>(contentsOf sequence: S) -> [Element] where Element == S.Element, S : Sequence {
        var result = [Element]()
        result.append(contentsOf: self)
        result.append(contentsOf: sequence)
        return result
    }
    
}

// MARK: - Array+Extensions where Element is Equatable
extension Array where Element: Equatable {
    mutating
    func remove(_ element: Element) {
        self.removeAll { $0 == element}
    }
    
    func permutations(ofSize size: Int, where isIncluded: (([Element]) -> Bool)?=nil) -> [[Element]] {
        guard size >= count else { return [] }

        var result = [[Element]]()

        if size == count {
            result = [self]
        } else if size == 1 {
            result = self.map { [$0] }
        } else {
            forEach { item in
                var array = [Element]().appending(contentsOf: self)
                array.remove(item)
                
                let subCombos = array.permutations(ofSize: size-1)
                result.append(
                    contentsOf:
                        subCombos.map {
                            [Element]()
                                .appending(item)
                                .appending(contentsOf: $0)
                        }
                )
            }
        }

        if let includedClause = isIncluded {
            result = result.filter(includedClause)
        }

        return result
    }
    
}

// MARK: - Array+Extensions where Element is Hashable
extension Array where Element: Hashable {
    func combinations(ofSize size: Int, where isIncluded: (([Element]) -> Bool)?=nil) -> [[Element]] {
        guard size <= count else { return [] }

        var result = [[Element]]()

        if size == count {
            result = [self]
        } else if size == 1 {
            result = self.map { [$0] }
        } else {
            
            for i in 0...count-size {
                var array = [Element]().appending(contentsOf: self)
                array.removeFirst(i+1)
                
                let subCombos = array.combinations(ofSize: size-1)
                result.append(
                    contentsOf:
                        subCombos.map {
                            [Element]()
                                .appending(self[i])
                                .appending(contentsOf: $0)
                        }
                )
            }
        }

        if let includedClause = isIncluded {
            result = result.filter(includedClause)
        }

        return result
    }
}

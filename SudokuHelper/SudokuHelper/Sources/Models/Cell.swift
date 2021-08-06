//
//  Cell.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation


final class Cell: Identifiable {
    static let validValues = Set<Int>(1...9)
    let id = UUID()

    var isPredefined: Bool
    var value: Int?
    var possibilities: Set<Int>
    
    weak var horizontalLine: Line?
    weak var verticalLine: Line?
    weak var square: Square?

    
    init(value: Int?=nil, isPredefined: Bool=false) {
        guard
            let value = value,
            Self.validValues.contains(value)
        else {
            self.isPredefined = false
            self.possibilities = Self.validValues
            return
        }

        self.value = value
        self.isPredefined = isPredefined
        possibilities = Set<Int>()
    }
    
}

// MARK: - Cell+Equatable
extension Cell: Equatable {
    static func == (lhs: Cell, rhs: Cell) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Cell+Hashable
extension Cell: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Cell {
    @discardableResult
    func set(value: Int) -> Set<Int> {
        guard
            Self.validValues.contains(value)
        else {
            assertionFailure("Attempted to set invalid cell value")
            return Set<Int>()
        }

        let others = possibilities.subtracting([value].set)
        self.value = value
        possibilities.removeAll()

        // TODO: Note that we can remove this as a possibility from associated groups
        
        return others
    }
    
    func sharesGroup(with cell: Cell?) -> Bool {
        guard
            let cell = cell
        else {
            return false
            
        }
        
        return (verticalLine?.contains(cell: cell) ?? false) ||
            (horizontalLine?.contains(cell: cell) ?? false) ||
            (square?.contains(cell: cell) ?? false)
    }
}


// MARK: - Printing
extension Cell {
    
    func printValue() -> String {
        if let value = value {
            return String(value)
        } else {
            return " "
        }
    }
    
}

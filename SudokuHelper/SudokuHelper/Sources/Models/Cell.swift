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
    var isSolved: Bool { value != nil }
    
    unowned var horizontalLine: Line!
    unowned var verticalLine: Line!
    unowned var square: Square!
    
    func line(axis: Line.Axis) -> Line {
        switch axis {
        case .horizontal:
            return horizontalLine
        case .vertical:
            return verticalLine
        }
    }

    
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
        return others
    }
    
    func sharesGroup(with cell: Cell?) -> Bool {
        guard
            let cell = cell
        else {
            return false
            
        }
        
        return verticalLine.contains(cell: cell) ||
            horizontalLine.contains(cell: cell) ||
            square.contains(cell: cell)
    }
    
    var siblings: Set<Cell> {
        var set = verticalLine.cells.set
        set.formUnion(horizontalLine.cells.set)
        set.formUnion(square.cells.set)
        set.remove(self)
        return set
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

//
//  Cell.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation


final class Cell: Identifiable {
    typealias Position = (x: Int, y: Int)
    static let validValues = Set<Int>(1...9)
    let id = UUID()

    var isPredefined: Bool
    var value: Int?
    var possibilities: Set<Int>
    var isSolved: Bool { value != nil }
    let position: Position

    weak var horizontalLine: Line?
    weak var verticalLine: Line?
    weak var square: Square?
    
    func line(axis: Line.Axis) -> Line? {
        switch axis {
        case .horizontal:
            return horizontalLine
        case .vertical:
            return verticalLine
        }
    }

    
    init(position: Position, value: Int?=nil, isPredefined: Bool=false) {
        self.position = position

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
    func set(value: Int) throws -> Set<Int> {
        
        // Already solved
        if value == self.value { return Set<Int>() }
        
        try validate(newValue: value)
        
        let others = possibilities.subtracting([value].set)
        self.value = value
        possibilities.removeAll()
        return others
    }
    
    private func validate(newValue: Int) throws {
        guard
            Self.validValues.contains(newValue)
        else {
            throw SolveError.attemptedToSetInvalidValue(value: newValue)
        }
        
        guard let horizontalLine, let verticalLine, let square else {
            throw SolveError.lostGroupReference
        }
        
        var conflictingGroups = [Group]()
        
        if horizontalLine.solvedValues.contains(newValue) {
            conflictingGroups.append(horizontalLine)
        }
        
        if verticalLine.solvedValues.contains(newValue) {
            conflictingGroups.append(verticalLine)
        }
        
        if square.solvedValues.contains(newValue) {
            conflictingGroups.append(square)
        }
        
        if conflictingGroups.isEmpty == false {
            throw SolveError.alreadySolvedInGroup(groups: conflictingGroups)
        }
    }
    
    func sharesGroup(with cell: Cell?) -> Bool {
        guard
            let cell = cell
        else {
            return false
            
        }
        
        return verticalLine?.contains(cell: cell) ?? false ||
            horizontalLine?.contains(cell: cell) ?? false ||
            square?.contains(cell: cell) ?? false
    }
    
    var siblings: Set<Cell> {
        var set = verticalLine?.cells.set ?? []
        set.formUnion(horizontalLine?.cells.set ?? [])
        set.formUnion(square?.cells.set ?? [])
        set.remove(self)
        return set
    }
}

extension Cell {
    enum SolveError: Error {
        case lostGroupReference
        case attemptedToSetInvalidValue(value: Int)
        case alreadySolvedInGroup(groups: [Group])
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

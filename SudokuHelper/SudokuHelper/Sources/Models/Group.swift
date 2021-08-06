//
//  Group.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation


protocol Group: AnyObject, Identifiable, Hashable {
    var id: UUID { get }
    var cells: [Cell] { get }
}

// MARK: - Cell value helpers
extension Group {
    var isSolved: Bool {
        remainingValues.isEmpty
    }
    
    var solvedValues: Set<Int> {
        cells.compactMap(\.value).set
    }

    var remainingValues: Set<Int> {
        Cell.validValues.subtracting(solvedValues)
    }
}

// MARK: - Possibility removal
extension Group {
    @discardableResult
    func remove(possibility: Int) -> Set<Cell> {
        cells.filter{ $0.possibilities.remove(possibility) != nil }.set
    }
    
    @discardableResult
    func remove(possibilities: Set<Int>) -> Set<Cell> {
        var cells = Set<Cell>()
        possibilities.forEach {
            cells = cells.union(self.remove(possibility: $0))
        }
        return cells
    }
    
    func contains(cell: Cell) -> Bool {
        cells.contains(cell)
    }
}

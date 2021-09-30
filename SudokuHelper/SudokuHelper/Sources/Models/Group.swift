//
//  Group.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation

protocol Group: NSObject {
    var id: UUID { get }
    var cells: [Cell] { get }
}

// MARK: - Cell value helpers
extension Group {
    var isSolved: Bool {
        remainingValues.isEmpty
    }
    
    var isValid: Bool {
        let cellPossibilities = cells
            .compactMap({ $0.isSolved ? nil : $0.possibilities })
            .flattened
            .set
    
        let solvedValues = cells
            .compactMap({ $0.isSolved ? $0.value : nil})
            .set
        
        let groupValues = solvedValues.union(cellPossibilities)
        
        let isValid = groupValues.isSubset(of: Cell.validValues) && groupValues.count == Cell.validValues.count
        
        if !isValid {
            print("This is not a valid group")
        }
        
        return isValid
    }
    
    var solvedValues: Set<Int> {
        cells.compactMap(\.value).set
    }

    var remainingValues: Set<Int> {
        Cell.validValues.subtracting(solvedValues)
    }
    
    var unsolvedCells: Set<Cell> {
        cells.filter({ !$0.isSolved }).set
    }

    func cells(containingPossibility possibility: Int) -> Set<Cell> {
        cells.filter({ $0.possibilities.contains(possibility) }).set
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
            cells.formUnion(self.remove(possibility: $0))
        }
        return cells
    }
    
    func contains(cell: Cell) -> Bool {
        cells.contains(cell)
    }
}

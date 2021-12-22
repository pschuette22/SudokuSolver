//
//  PuzzleViewState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/21/21.
//

import Foundation

struct PuzzleViewState: ViewState {
    private(set) var cellStates: [[CellViewState]]
    
    init(cells: [[Cell]], focused: Cell?) {
        cellStates = cells.enumerated().map { y, row in
            row.enumerated().map { x, cell in
                return CellViewState(
                    cell: cell,
                    at: (x: x, y: y),
                    isFocused: cell == focused,
                    isHighlighted: cell.sharesGroup(with: focused))
            }
        }
    }
}

// MARK: - Transactions

extension PuzzleViewState {
    mutating
    func set(cellStates: [[CellViewState]]) {
        self.cellStates = cellStates
    }
}

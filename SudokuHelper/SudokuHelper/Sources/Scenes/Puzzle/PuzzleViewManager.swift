//
//  PuzzleViewManager.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation

// MARK: - CellViewState
struct CellViewState: ViewState {
    let location: Puzzle.Location
    let value: Int?
    let isValueBold: Bool
    let possibilities: Set<Int>
    let isFocued: Bool
    let isHighlighted: Bool
    
    init(
        cell: Cell,
        at location: Puzzle.Location,
        isFocued: Bool=false,
        isHighlighted: Bool=false
    ) {
        self.location = location
        value = cell.value
        isValueBold = cell.isPredefined
        possibilities = cell.possibilities
        self.isFocued = isFocued
        self.isHighlighted = isHighlighted
        // TODO: setup group highlighting
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine("x:\(location.x),y:\(location.y)")
        hasher.combine(value ?? 0)
        hasher.combine(isValueBold)
        hasher.combine(possibilities)
        hasher.combine(isFocued)
        hasher.combine(isHighlighted)
    }
    
    static func == (lhs: CellViewState, rhs: CellViewState) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

// MARK: - PuzzleViewState
struct PuzzleViewState: ViewState {
    let cellStates: [[CellViewState]]
    
    init(cells: [[Cell]], focused: Cell?) {
        cellStates = cells.enumerated().map { y, row in
            row.enumerated().map { x, cell in
                return CellViewState(
                    cell: cell,
                    at: (x: x, y: y),
                    isFocued: cell == focused,
                    isHighlighted: cell.sharesGroup(with: focused))
            }
            
        }
    }
}

// MARK: - PuzzleViewManager
final class PuzzleViewManager: ViewManager {
    typealias ViewState = PuzzleViewState
    enum StateChange {
        
    }
    
    private(set) var state: PuzzleViewState
    private var puzzle: Puzzle
    
    required init(puzzle: Puzzle) {
        self.puzzle = puzzle
        self.state = PuzzleViewState(cells: puzzle.cells, focused: nil)
    }
    
}

//
//  PuzzleViewModel.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation
import Combine

// MARK: - CellViewState
struct CellViewState: ViewState {
    let location: Puzzle.Location
    let value: Int?
    let isValueBold: Bool
    let possibilities: Set<Int>
    let isFocused: Bool
    let isHighlighted: Bool
    
    init(
        cell: Cell,
        at location: Puzzle.Location,
        isFocused: Bool=false,
        isHighlighted: Bool=false
    ) {
        self.location = location
        value = cell.value
        isValueBold = cell.isPredefined
        possibilities = cell.possibilities
        self.isFocused = isFocused
        self.isHighlighted = isHighlighted
        // TODO: setup group highlighting
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine("x:\(location.x),y:\(location.y)")
        hasher.combine(value ?? 0)
        hasher.combine(isValueBold)
        hasher.combine(possibilities)
        hasher.combine(isFocused)
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
                    isFocused: cell == focused,
                    isHighlighted: cell.sharesGroup(with: focused))
            }
        }
    }
}

// MARK: - PuzzleViewManager
final class PuzzleViewControllerModel: ViewModel<PuzzleViewState> {
    convenience init(puzzle: Puzzle) {
        let state = PuzzleViewState(cells: puzzle.cells, focused: nil)
        self.init(initialState: state)
    }
    
    required init(initialState state: PuzzleViewState) {
        super.init(initialState: state)
    }
}

// MARK: - PuzzleViewDelegate

extension PuzzleViewControllerModel: PuzzleViewDelegate {
    func didTapCell(at position: Puzzle.Location) {
        Logger.log(.warning, message: "Did tap cell!", params: ["position": position])
    }
}

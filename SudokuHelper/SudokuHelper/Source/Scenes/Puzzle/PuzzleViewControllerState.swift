//
//  PuzzleViewControllerState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/22/21.
//

import Foundation

struct PuzzleViewControllerState: ViewState {
    private(set) var puzzleViewState: PuzzleViewState
    private(set) var inputControlBarState: InputControlBarViewState
    
    init(
        puzzleViewState: PuzzleViewState,
        inputControlBarState: InputControlBarViewState = .init()
    ) {
        self.puzzleViewState = puzzleViewState
        self.inputControlBarState = inputControlBarState
    }
}

extension PuzzleViewControllerState {
    mutating
    func set(puzzleCellViewStates: [[CellViewState]]) {
        puzzleViewState.set(cellStates: puzzleCellViewStates)
    }
}

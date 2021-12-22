//
//  CellViewState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/21/21.
//

import Foundation

struct CellViewState: ViewState {
    let location: Puzzle.Location
    private(set) var value: Int?
    private(set) var isValueBold: Bool
    private(set) var possibilities: Set<Int>
    private(set) var isFocused: Bool
    private(set) var isHighlighted: Bool
    
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

// MARK: - Transactions

extension CellViewState {
    mutating
    func set(isHighlighted: Bool) {
        self.isHighlighted = isHighlighted
    }
    
    mutating
    func set(isFocused: Bool) {
        self.isFocused = isFocused
    }
}

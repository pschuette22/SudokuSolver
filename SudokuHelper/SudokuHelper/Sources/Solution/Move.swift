//
//  Move.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/7/21.
//

import Foundation


/// Reason for placing a given move
enum Strategy: String {
    /// Value was solved because it is the last possibility in a cell
    case singlePossibilityInCell
    /// Value was solved because it is the last possibility in a given group
    case singlePossibilityInGroup
    /// Possibile value was eliminated because it was solved in a group sibling
    case solvedInSibling
    /// Possibile value was elimited because there are limited possibilities in this group
    case limitedPossibilitiesInGroup
    /// Possible value was elimited because it is required in an adjacent group
    case valueRequiredInAdjacentGroup
    case xWing
    case swordFish
}

enum Move {
    case eliminate(_ possibility: Int, _ cell: Cell, _ strategy: Strategy)
    case solve(_ value: Int, _ cell: Cell, _ strategy: Strategy)
    
    var value: Int {
        switch self {
        case let .eliminate(value, _, _),
             let .solve(value, _, _):
            return value
        }
    }
    
    var cell: Cell {
        switch self {
        case let .eliminate(_, cell, _),
             let .solve(_ , cell, _):
            return cell
        }
    }
    
    var strategy: Strategy {
        switch self {
        case let .eliminate(_, _, strategy),
             let .solve(_, _, strategy):
            return strategy
        }
    }
}

// MARK: - Move+Hashable
extension Move: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        // If these ever colide, it is a bug
        case let .eliminate(value, cell, _),
             let .solve(value, cell, _):
            hasher.combine(value)
            hasher.combine(cell.hashValue)
        }
    }
}

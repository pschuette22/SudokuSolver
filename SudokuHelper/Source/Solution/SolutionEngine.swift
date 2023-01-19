//
//  SolutionEngine.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/7/21.
//

import Foundation

public class SolutionEngine {
    let puzzle: Puzzle

    private(set) var history = [Move]()
    var strategiesUsed: Set<Strategy> {
        history.reduce(into: Set<Strategy>()) { $0.insert($1.strategy) }
    }
    
    private var availableMoves = Set<Move>()
    
    init(puzzle: Puzzle) {
        self.puzzle = puzzle
    }
}

// MARK: - Move execution
extension SolutionEngine {
    @discardableResult
    func execute(_ move: Move) throws -> Set<Move> {
        var resultingMoves = Set<Move>()
        
        switch move {
        case let .eliminate(possibility, cell, _):
            
            if
                cell.possibilities.remove(possibility) != nil,
                cell.possibilities.count == 1
            {
                resultingMoves.insert(.solve(cell.possibilities.first!, cell, .singlePossibilityInCell))
            } // TODO: else, use this to kick off finding other moves efficiently
            
        case let .solve(value, cell, _):
            try cell.set(value: value)
            cell.siblings.forEach { cell in
                guard cell.possibilities.contains(value) else { return }
                    
                resultingMoves.insert(.eliminate(value, cell, .solvedInSibling))
            }
        }
        
        history.append(move)
        
        if !puzzle.isValid {
            print("puzzle is not valid!")
            print(history.reduce(into: Set<String>(), { $0.insert($1.strategy.rawValue) }))
            print("\n")
            print(history.map({ $0.strategy.rawValue }))
            print("\n")
        }
        
        
        return resultingMoves
    }
    
    
    // MARK: - Solve the puzzle
    @discardableResult
    func solve() throws -> Bool {
        while !availableMoves.isEmpty || !puzzle.isSolved {
            if !availableMoves.isEmpty {
                let move = availableMoves.removeFirst()
                let resultingMoves = try execute(move)
                
                if !resultingMoves.isEmpty {
                    availableMoves.formUnion(resultingMoves)
                }
                
                continue
            }
            
            let moveFindingTasks: [() -> Void] = [
                // This first one should be redundant, but it is quick so a double check is fine
                { self.availableMoves.formUnion(self.singlePossibilityInCellMoves()) },
                { self.availableMoves.formUnion(self.singlePossibilityInGroupMoves()) },
                { self.availableMoves.formUnion(self.solvedInSiblingCellMoves()) },
                { self.availableMoves.formUnion(self.limitedPossibilitiesInGroupMoves()) },
                { self.availableMoves.formUnion(self.requiredInAdjacentGroupMoves()) },
                { self.availableMoves.formUnion(self.swordFishEliminationMoves()) },
            ]
            
            for task in moveFindingTasks {
                guard availableMoves.isEmpty else { break }

                task()
            }
            
            if availableMoves.isEmpty {
                break
            }
        }
        
        
        return puzzle.isSolved
    }
}

// MARK: - Move finding
extension SolutionEngine {
    func singlePossibilityInCellMoves(_ cells: [Cell]?=nil) -> Set<Move> {
        (cells ?? puzzle.cells.flattened)
            .compactMap { cell in
                guard
                    !cell.isSolved
                    && cell.possibilities.count == 1
                else {
                    return nil
                }
                
                return Move.solve(cell.possibilities.first!, cell, .singlePossibilityInCell)
            }.set
    }
    
    func singlePossibilityInGroupMoves(_ groups: [Group]?=nil) -> Set<Move> {
        var moves = Set<Move>()
        (groups ?? puzzle.groups).forEach { group in
            group.remainingValues.forEach { [group] value in
                let remainingCells = group.cells(containingPossibility: value)
                
                guard
                    remainingCells.count == 1,
                    let cell = remainingCells.first
                else { return }
                
                moves.insert(.solve(value, cell, .singlePossibilityInGroup))
            }
        }
        return moves
    }
    
    func solvedInSiblingCellMoves(_ cells: [Cell]?=nil) -> Set<Move> {
        (cells ?? puzzle.cells.flattened)
            .filter { $0.isSolved }
            .compactMap { cell -> [Move]? in
                guard let value = cell.value else { return nil }
                
                return cell.siblings
                    .filter({ $0.possibilities.contains(value) })
                    .map({ Move.eliminate(value, $0, .solvedInSibling) })
            }
            .flattened
            .set
    }
    
    /// If there is some combination of X cells in a given group whose given count of aggregated possibilities
    /// is equal to X, we may remove these possibilites from all other cells in the group
    /// - Parameter groups: (optional) list of groups we wish to check for limited possibilities elimination. If none are passed, all puzzle groups are checked
    /// - Returns: Set of elimination moves which come as a result of limited possibilites in groups
    func limitedPossibilitiesInGroupMoves(_ groups: [Group]?=nil) -> Set<Move> {
        var moves = Set<Move>()
        (groups ?? puzzle.groups).forEach { group in
            let remainingValues = group.remainingValues

            guard remainingValues.count > 2 else { return }
            
            for limit in 2..<remainingValues.count {
                // All combinations of cells where possibilities == count of cells in combination

                let combinations = group.cells
                    .filter({ !$0.isSolved })
                    .combinations(ofSize: limit) { cells in
                    let combinedPossibilities = cells.reduce(into: Set<Int>()) { $0.formUnion($1.possibilities) }
                    // if combinedPossibilities.count < limit, we have reached an error state
                    // TODO: handle error states when identified to avoid further computations
                    if combinedPossibilities.count < limit {
                        // We are in an error state
                        assertionFailure("Error state reached when looking for limited possibilities in groups")
                    }
                    return combinedPossibilities.count <= limit
                }
                
                // No combination of cells have remove candidates
                if combinations.isEmpty { continue }
             
                let removeCandidates = group.unsolvedCells
                combinations.forEach { combination in
                    let combinationValues = combination.reduce(into: Set<Int>()) { $0.formUnion($1.possibilities) }
                    let removable = removeCandidates.filter { !combination.contains($0) }
                    removable.forEach { cell in
                        let nonpossibilities = cell.possibilities.intersection(combinationValues)
                        nonpossibilities.forEach {
                            moves.insert(.eliminate($0, cell, .limitedPossibilitiesInGroup))
                        }
                    }
                }
                
            }
        }

        return moves
    }
    
    
    
    /// When all cells containing a possibility for a square group exist in one vertical or horizontal line group, that possibility
    /// may be removed from all cells in the vertical or horizontal line group containig the possibility
    /// - Returns: A set of required in adjacent group moves
    func requiredInAdjacentGroupMoves() -> Set<Move> {
        var moves = Set<Move>()
        
        puzzle.squares.forEach { square in
            square.remainingValues.forEach { value in
                let squareCells = square.cells(containingPossibility: value)
                guard (2...3).contains(squareCells.count) else { return }
                
                let verticalLines = squareCells
                    .reduce(into: Set<Line>()) { $0.insert($1.verticalLine) }
                    .compactMap { $0 }
                let horizontalLines = squareCells
                    .reduce(into: Set<Line>()) { $0.insert($1.horizontalLine) }
                    .compactMap { $0 }
                
                if
                    verticalLines.count == 1,
                    let verticalLine = verticalLines.first
                {
                    verticalLine
                        .cells(containingPossibility: value)
                        .subtracting(squareCells)
                        .forEach {
                            moves.insert(.eliminate(value, $0, .valueRequiredInAdjacentGroup))
                        }
    
                } else if
                    horizontalLines.count == 1,
                    let horizontalLine = horizontalLines.first
                {
                    horizontalLine
                        .cells(containingPossibility: value)
                        .subtracting(squareCells)
                        .forEach {
                            moves.insert(.eliminate(value, $0, .valueRequiredInAdjacentGroup))
                        }
                }
            }
        }
        
        return moves
    }
    
        
    
    /// X-Wing elimination:
    /// When there are exactly two positiions on a given line that contain a 
    /// - Returns: Set of
    func swordFishEliminationMoves() -> Set<Move> {
        // TODO: Support adding a single-cell seed ?
        var moves = Set<Move>()
        let values = puzzle.remainingValues

        outer:  for axis in Line.Axis.allCases {
            let otherAxis = axis.other
            for value in values {
                let lines = puzzle.lines(withAxis: axis)
                    .filter { !$0.isSolved && $0.cells(containingPossibility: value).count == 2 }
                
                guard lines.count > 1 else { continue }
                
                for lineCount in 2...lines.count {
                    for lineCombo in lines.combinations(ofSize: lineCount) {
                        let evaluatingCells = lineCombo.reduce(into: Set<Cell>()) { result, line in
                            result.formUnion(line.cells(containingPossibility: value))
                        }
                        
                        let otherAxisLines = evaluatingCells.reduce(into: Set<Line>()) { result, cell in
                            result.insert(cell.line(axis: otherAxis))
                        }
                        
                        if otherAxisLines.count == lineCount {
                            // There are an even number of lines on each axis.
                            let removeCells = otherAxisLines.reduce(into: Set<Cell>(), { $0.formUnion($1?.cells(containingPossibility: value) ?? []) })
                                .subtracting(evaluatingCells)
                            
                            removeCells.forEach {
                                moves.insert(.eliminate(value, $0, lineCount == 2 ? .xWing : .swordFish))
                            }
                        }

                        if !moves.isEmpty { break outer }

                    }
                    
                    if !moves.isEmpty { break outer }

                }
                
                if !moves.isEmpty { break outer }
            }
            
            // Since this is an expensive op and this move tends to open up the board for other solves
            // we will exit early and try to solve the puzzle other ways
            if !moves.isEmpty { break }
        }
        
        return moves
    }
    
    // TODO: optimize solving by seeding move testing after value eliminations
//    func movesAfterEliminating(value: Int, in cell: Cell) -> [Move] {
//        var moves = [Move]()
//        // If this
//        if
//            cell.possibilities.count == 1,
//            let value = cell.possibilities.first
//        {
//            moves.append(.solve(value, cell, .singlePossibilityInCell))
//        }
//
//
//        // TODO: Look into optimizations for searching for moves after elimitating a possibility
//
//        return moves
//    }
//
//    func movesAfterSolving(for value: Int, in cell: Cell) -> [Move] {
//        cell.siblings.filter(
//            { !$0.isSolved && $0.possibilities.contains(value) }
//        ).map {
//            .eliminate(value, $0, .solvedInSibling)
//        }
//    }
}

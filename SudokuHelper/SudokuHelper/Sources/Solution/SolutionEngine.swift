//
//  SolutionEngine.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/7/21.
//

import Foundation

public class SolutionEngine {
    let puzzle: Puzzle

    private var history = [Move]()
    
    private var availableMoves = Set<Move>()
    
    init(puzzle: Puzzle) {
        self.puzzle = puzzle
    }
}

// MARK: - Move execution
extension SolutionEngine {
    @discardableResult
    func execute(_ move: Move) -> Set<Move> {
        history.append(move)
        var resultingMoves = Set<Move>()
        
        switch move {
        case let .eliminate(possibility, cell, _):
            cell.possibilities.remove(possibility)
            // TODO: use this to kick off finding other moves efficiently
        case let .solve(value, cell, _):
            cell.set(value: value)
            cell.siblings.forEach { cell in
                if cell.possibilities.contains(value) {
                    resultingMoves.insert(.eliminate(value, cell, .solvedInSibling))
                }
            }
        }
        
        return resultingMoves
    }
    
    
    // MARK: - Solve the puzzle
    @discardableResult
    func solve() -> Bool {
        while !availableMoves.isEmpty || !puzzle.isSolved {
            if !availableMoves.isEmpty {
                let resultingMoves = execute(availableMoves.removeFirst())
                
                if !resultingMoves.isEmpty {
                    availableMoves.formUnion(resultingMoves)
                }
                
                continue
            }
            

            let moveFindingTasks: [() -> Void] = [
                { self.availableMoves.formUnion(self.singlePossibilityInCellMoves()) },
                { self.availableMoves.formUnion(self.singlePossibilityInGroupMoves()) },
                { self.availableMoves.formUnion(self.limitedPossibilitiesInGroupMoves()) },
                { self.availableMoves.formUnion(self.requiredInAdjacentGroupMoves()) },
                { self.availableMoves.formUnion(self.swordFishEliminationMoves()) }
            ]
            
            for task in moveFindingTasks {
                if !availableMoves.isEmpty {
                    break
                }
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
private extension SolutionEngine {
    func singlePossibilityInCellMoves(_ cells: [Cell]?=nil) -> Set<Move> {
        (cells ?? puzzle.cells.flattened)
            .filter { !$0.isSolved && $0.possibilities.count == 1 }
            .map {
                Move.solve($0.possibilities.first!, $0, .singlePossibilityInCell)
            }.set
    }
    
    func singlePossibilityInGroupMoves(_ groups: [Group]?=nil) -> Set<Move> {
        // TODO: single possibility in group solve
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
    
    
    /// If there is some combination of X cells in a given group whose given count of aggregated possibilities
    /// is equal to X, we may remove these possibilites from all other cells in the group
    /// - Parameter groups: (optional) list of groups we wish to check for limited possibilities elimination. If none are passed, all puzzle groups are checked
    /// - Returns: Set of elimination moves which come as a result of limited possibilites in groups
    func limitedPossibilitiesInGroupMoves(_ groups: [Group]?=nil) -> Set<Move> {
        var moves = Set<Move>()
        (groups ?? puzzle.groups).forEach { group in
            let remainingValues = group.remainingValues

            for limit in 2..<remainingValues.count {
                // All combinations of cells where possibilities == count of cells in combination

                let combinations = group.cells.combinations(ofSize: limit) { cells in
                    let combinedPossibilities = cells.reduce(Set<Int>()) { $0.union($1.possibilities) }
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
                    let combinationValues = combination.reduce(Set<Int>()) { $0.union($1.possibilities) }
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
                guard squareCells.count <= 3 else { return }
                
                let verticalLines = squareCells.reduce(into: Set<Line>(), { $0.insert($1.verticalLine) })
                let horizontalLines = squareCells.reduce(into: Set<Line>(), { $0.insert($1.horizontalLine) })
                
                if
                    verticalLines.count == 1
                {
                    verticalLines.first??
                        .cells(containingPossibility: value)
                        .subtracting(squareCells)
                        .forEach {
                            moves.insert(.eliminate(value, $0, .valueRequiredInAdjacentGroup))
                        }
    
                } else if
                    horizontalLines.count == 1
                {
                    horizontalLines.first??
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

        for axis in Line.Axis.allCases {
            let otherAxis = axis.other
            for value in values {
                let lines = puzzle.lines(withAxis: axis)
                    .filter { !$0.isSolved && $0.cells(containingPossibility: value).count == 2 }
                
                guard lines.count > 1 else { break }
                
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
                            let removeCells = otherAxisLines.reduce(into: Set<Cell>(), { $0.formUnion($1.cells(containingPossibility: value)) })
                                .subtracting(evaluatingCells)
                            
                            removeCells.forEach {
                                moves.insert(.eliminate(value, $0, lineCount == 2 ? .xWing : .swordFish))
                            }
                        }

                        if !moves.isEmpty { break }

                    }
                    
                    if !moves.isEmpty { break }

                }
                
                if !moves.isEmpty { break }
            }
            
            // Since this is an expensive op and this move tends to open up the board for other solves
            // we will exit early and try to solve the puzzle other ways
            if !moves.isEmpty { break }
        }
        
        return moves
    }
    
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

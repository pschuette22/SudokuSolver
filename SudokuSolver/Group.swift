//
//  Group.swift
//  SudokuSolver
//
//  Created by Schuette, Peter on 12/24/16.
//  Copyright © 2016 Schuette, Peter. All rights reserved.
//

import Foundation


class Group {
    
//    // Prime value sum of all solved cell values
//    var primeSum: UInt { get set }
    
    
    var cells: [Cell]!
    
    
    var solved = 0

    
    var isComplete: Bool {
        get {
            return solved == 9
        }
    }
    
    
    func didSolve(cell: Cell) {
        
        if let value = cell.value {
            solved += 1
            for mCell in cells {
                mCell.removePossible(value: value)
            }
        }
    }
    
    
    
    func lastPossibilityElimination() {
        
        for i in 1...9 {
            
            let iCells = cells.filter({!$0.isSolved && $0.possibleValues.contains(UInt(i))})
            
            if iCells.count == 1 {
                board.possibilityChangedMade += (iCells[0].possibleValues.count - 1)
                iCells[0].possibleValues.removeAll()
                iCells[0].possibleValues.append(UInt(i))
                board.addSolvable(cell: iCells[0])
                
            }
            
        }
        
    }
    
    
    // Eliminate possible groupings based on similar possibilities in
    // Returns if possibilities were removed based on
    func didGroupingElimination() -> Bool {
        
        if !isComplete {
            let orderedArr = cells.filter({!$0.isSolved}).sorted(by: {$0.possibilities < $1.possibilities})
            
            for cellsInvolved in orderedArr[0].possibilities...orderedArr.last!.possibilities {
                if cellsInvolved < 9-solved {
                    // Possibilities in
                    let potentialCells = orderedArr.filter({$0.possibilities <= cellsInvolved})
                    
                    if potentialCells.count >= cellsInvolved {
                        let combos = combinations(cells: potentialCells, count: cellsInvolved)
                        
                        for combo in combos {
                            var possibleValues: [UInt] = []
                            for cell in combo {
                                for possibility in cell.possibleValues {
                                    if possibleValues.index(of: possibility) == nil {
                                        // Possibility is not in possible values
                                        possibleValues.append(possibility)
                                    }
                                }
                            }
                            
                            if possibleValues.count == cellsInvolved {
                                // Possible values is equal to the number of cells involved, can remove all of these possible values from cells that are not part of this combo
                                
                                // Unsolved cells that do not exist in this
                                let unrelatedCells = cells.filter({!$0.isSolved && combo.index(of: $0)==nil})
                                
                                for unrelated in unrelatedCells {
                                    for value in possibleValues {
                                        unrelated.removePossible(value: value)
                                    }
                                }
                                
                                // Return true, grouping elimination did occur
                                return true
                            }
                            
                        }
                        
                        
                }
                }
                
            }
            
            
        }
        
        return false
    }
    
    
    
    // Calculates all the combinations of cells for a given count
    // Based on http://stackoverflow.com/questions/25162500/apple-swift-generate-combinations-with-repetition
    func combinations(cells: [Cell], count: Int) -> [[Cell]] {

        if cells.count == count {
            return [cells]
        }
        
        var result: [[Cell]]!
        
        if count > 0 {
            
            if count == 1 {
                result = cells.map({[$0]})
            } else {
                result = []
                let rest = Array(cells.suffix(from: 1))
                let sub_combos = combinations(cells: rest, count: count-1)
                
                let mappedCombos = sub_combos.map( { [cells[0]] + $0 } )
                for arr in mappedCombos {
                    result.append(arr)
                }
                
                for combo in combinations(cells: rest, count: count) {
                    result.append(combo)
                }
                
            }
            
        }
        
        return result
    }
    
    
}

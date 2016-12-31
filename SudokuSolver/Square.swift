//
//  Square.swift
//  SudokuSolver
//
//  Created by Schuette, Peter on 12/24/16.
//  Copyright © 2016 Schuette, Peter. All rights reserved.
//

import Foundation


class Square: Group {
    
//    open var primeSum: UInt = 0
    
    /**
     3x3 array of cells
     X X X
     X X X
     X X X
    */
    open var sqCells: [[Cell]]
    
    // Initialize the square group with a 3x3 array of arrays of cells
    init(sqCells: [[Cell]]) {

        self.sqCells = sqCells
        
        super.init()
        
        self.cells = []
        for row in sqCells {
            for cell in row {
                cells.append(cell)
                cell.groups.append(self)
            }
        }
        
    }
    
    func didDoubleGroupingElimination() -> Bool {
        
        for i in 1...9 {
            
            let iCells = cells.filter({!$0.isSolved && $0.possibleValues.contains(UInt(i))})

            if iCells.count == 2 || iCells.count == 3 {
                // If execution block enters here, there are 2 or 3 cells containing possible value
                
                let x = iCells[0].x
                var isSameX = true
                let y = iCells[0].y
                var isSameY = true
                
                for j in 1..<iCells.count {
                    if iCells[j].x != x {
                        isSameX = false
                    }
                    
                    if iCells[j].y != y {
                        isSameY = false
                    }
                }
                
                if isSameY {
                    
                    let yRow = board.rows[y]
                    
                    for cell in yRow.cells {
                        if iCells.index(of: cell) == nil {
                            cell.removePossible(value: UInt(i))
                        }
                    }
                    
                    return true
                } else if isSameX {
                    
                    let xColumn = board.columns[x]
                    
                    for cell in xColumn.cells {
                        if iCells.index(of: cell) == nil {
                            cell.removePossible(value: UInt(i))
                        }
                    }
                    
                    return true
                }
                
            }
            
        }
        
        return false
    }
    
    
    
}

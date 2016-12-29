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
    
    
}

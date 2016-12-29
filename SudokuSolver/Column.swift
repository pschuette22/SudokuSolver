//
//  Column.swift
//  SudokuSolver
//
//  Created by Schuette, Peter on 12/24/16.
//  Copyright © 2016 Schuette, Peter. All rights reserved.
//

import Foundation

/**
 Column is an extension of row, rotated 90 degrees
*/
class Column: Row {
        
    // Override the initialize and set vertical property
    override init(index: Int, cells: [Cell]) {
        super.init(index: index, cells: cells)
        
        self.isVertical = true
    }
    
}

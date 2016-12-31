//
//  Cell.swift
//  SudokuSolver
//
//  Created by Schuette, Peter on 12/24/16.
//  Copyright © 2016 Schuette, Peter. All rights reserved.
//

import Foundation


class Cell: Equatable {
    

    // Coordinates of this cell
    var x: Int
    var y: Int
    
    // Actual value of this cell or nil if unsolved
    var value: UInt? {
        didSet {
            board.solvedCells += 1
            possibleValues.removeAll()
            // Let holding column, row, square know cell was solved
            for group in groups {
                group.didSolve(cell: self)
            }
        }
    }
    
    // variable indicating the cell has been solved
    var isSolved: Bool {
        get {
            return value != nil
        }
    }
    
    // Array of possible values for this cell
    var possibleValues: [UInt] = [1,2,3,4,5,6,7,8,9]
    
    
    // Count for the number of possible values
    var possibilities: Int {
        get {
            return possibleValues.count
        }
    }
    
    
    // Maintain reference to Board cell exists in
    var board:Board!
    
    
    // List of groups this cell belongs to
    var groups: [Group] = []
    
    
    /**
     Initialize a cell with optional value
    */
    init(x: Int, y: Int) {
        
        self.x = x
        self.y = y
    }
    
    /**
     Remove a possible value for this cell
    */
    func removePossible(value: UInt) {
        if let index = possibleValues.index(of: value) {
            possibleValues.remove(at: index)
            board.possibilityChangedMade+=1
        }
        
        // If there is only one cell left, this is a solvable cell
        if possibilities == 1 {
            board.addSolvable(cell: self)
        }
        
    }
    
    
    func solve() {
        if possibleValues.count == 1 {
            value = possibleValues[0]
        }
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Cell, rhs: Cell) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
}

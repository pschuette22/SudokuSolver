//
//  Board.swift
//  SudokuSolver
//
//  Created by Schuette, Peter on 12/24/16.
//  Copyright © 2016 Schuette, Peter. All rights reserved.
//

import Foundation
import IOKit

class Board {
    
    var cells: [[Cell]] = []
    
    var rows: [Row] = []
    
    var columns: [Column] = []
    
    var squares: [[Square]] = []
    
    var groups: [Group] = []
    
    // List of cells that are ready to be solved
    var solveable:[Cell] = []
    
    
    var solvedCells = 0
    
    var possibilityChangedMade = 0
    
    
    init(values: [[Int]]) {
        
        
        // Initialize the cells
        for x in 0 ..< 9 {
            var row:[Cell] = []
            for y in 0 ..< 9 {
                
                let cell = Cell(x: x, y: y)
                cell.board = self
                row.append(cell)
            }
            cells.append(row)
        }
        
        
        // Initialize the rows
        for y in 0..<9 {
            var rowCels:[Cell] = []
            for x in 0..<9 {
                let cell = (cells[x])[y]
                rowCels.append(cell)
            }
            let row = Row(index: y, cells: rowCels)
            rows.append(row)
            groups.append(row)
        }
        
        // Initialize the columns
        for x in 0..<9 {
            var columnCells: [Cell] = []
            for y in 0..<9 {
                columnCells.append((cells[x])[y])
            }
            let column = Column(index: x, cells: columnCells)
            columns.append(column)
            groups.append(column)
        }
        
        // Initialize the squares
        for x1 in 0..<3 {
            var sqRow: [Square] = []
            for y1 in 0..<3 {
                var sqCells: [[Cell]] = []
                
                for x2 in 0..<3 {
                    var sqRowCells: [Cell] = []
                    let x = (3*x1)+x2
                    for y2 in 0..<3 {
                        let y = (3*y1) + y2
                        
                        sqRowCells.append((cells[x])[y])
                    }
                    sqCells.append(sqRowCells)
                }
                
                let square = Square(sqCells: sqCells)
                sqRow.append(square)
                groups.append(square)
            }
            squares.append(sqRow)
        }
        
        
        // Set the values of the cells
        // Initialize the cells
        for x in 0 ..< 9 {
            for y in 0 ..< 9 {
                let value = (values[x])[y]
                if value > 0 {
                    ((cells[x])[y]).value = UInt(value)
                }
            }
        }
        
        
    }
    
    
    func print() {
        // Print the board
        
        for x in 0..<9 {
            
            var str = ""
            
            for y in 0..<9 {
                
                if y%3 == 0 {
                    str+="|"
                }
                
                if let rowVal = (cells[x])[y].value {
                    str += "\(rowVal)."
                } else {
                    str += " ."
                }
                
                if y == 8 {
                    str+="|"
                }
                
            }
            
            if x%3 == 0{
                debugPrint("+------+------+------+")
            }
            
            debugPrint(str)
            
            if x == 8{
                debugPrint("+------+------+------+")
            }
        }
        
    }
    
    
    func addSolvable(cell: Cell) {
        if solveable.index(of: cell) == nil {
            solveable.append(cell)
        }
    }
    
    func solve() {
        
        var isSolved = false
        
        while !isSolved {
            while !solveable.isEmpty {
                solveable[0].solve()
                solveable.remove(at: 0)
            }
            
            // If there are no directly solvable cells, but not all cells are solved look for in-group eliminations
            if solvedCells < 81 {
                
                possibilityChangedMade = 0
                // Check to see if any values are the last possibility
                for group in groups {
                    group.lastPossibilityElimination()
                }
                
                // If solvable cells were found, continue
                if !solveable.isEmpty {
                    continue
                }
                
                
                for group in groups {
                    
                    // Try to do grouping elimination. Break out when cells have become solvable
                    if group.didGroupingElimination() && !solveable.isEmpty {
                        break
                    }
                    
                }
                
                // If solvable cells were found, continue
                if !solveable.isEmpty {
                    continue
                }
                
                // Do double grouping elimination

                for i in 0..<9 {
                    
                    let square = (squares[i/3])[i%3]
                    if square.didDoubleGroupingElimination() && !solveable.isEmpty {
                        break
                    }
                }
                
                // Do x wing elimination
                
                
                if possibilityChangedMade == 0 && solveable.isEmpty {
                    debugPrint("Unable to solve puzzle")
                    break
                }
                
            } else {
                isSolved = true
            }
            
        }
    }
    
    
}

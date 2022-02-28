//
//  main.swift
//  SudokuSolver
//
//  Created by Schuette, Peter on 12/24/16.
//  Copyright © 2016 Schuette, Peter. All rights reserved.
//

import Foundation


print("Welcome to the sudoku solver!")
print("Lets solve a sudoku\n\n")
var keepRunning = true

while keepRunning {
    print("Enter the sudoku by entering 9 characters. 1-9 indicates a prefilled space, 0 or space an empty cell")
    var inputArray = [[Int]]()
    for _ in 0..<9 {
        var line = readLine()?.replacingOccurrences(of: " ", with: "0") ?? "000000000"
        let validSet = CharacterSet(charactersIn: "0123456789")
        line = line.components(separatedBy: validSet.inverted).joined()
        if line.count < 9 {
            line.append(contentsOf: String(repeating: "0", count: 9 - line.count))
        } else if line.count > 9 {
            line.removeLast(line.count - 9)
        }
        let mapped = line.compactMap { Int("\($0)") }
        inputArray.append(mapped)
    }
    let puzzle = Puzzle(values: inputArray)
    let engine = SolutionEngine(puzzle: puzzle)
    if engine.solve() == true {
        puzzle.print()
    } else {
        print("failed to solve puzzle")
    }
    
    
    while true {
        print("\n\ndo another? y / n")
        let input = readLine()
        if input?.lowercased().starts(with: "y") ?? false {
            break
        } else if input?.lowercased().starts(with: "n") ?? false {
            keepRunning = false
            break
        } else {
            print("didn't catch that")
        }
    }
}

print("I enjoyed solving sudokus!")

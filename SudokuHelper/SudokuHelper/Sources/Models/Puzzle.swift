//
//  Puzzle.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation
import CoreGraphics

class Puzzle {
    typealias Location = (x: Int, y: Int)

    let id = UUID()
    let cells: [[Cell]]
    private(set) var verticalLines = [Line]()
    private(set) var horizontalLines = [Line]()
    private(set) var squares = [Square]()
    
    var groups: [Group] {
        var groups = [Group]()
        groups.append(contentsOf: verticalLines)
        groups.append(contentsOf: horizontalLines)
        groups.append(contentsOf: squares)
        return groups
    }
    
    // TODO: Revisit how this is done.
    // We should not calculate it every time
    
    /// Find all the possibilities left in the puzzle
    var remainingValues: Set<Int> {
        return cells
            .flattened
            .reduce(into: Set<Int>()) { result, cell in
                guard !cell.isSolved else { return }

                result.formUnion(cell.possibilities)
            }
    }
    
    var isSolved: Bool {
        cells
            .flattened
            .filter { !$0.isSolved }
            .isEmpty
    }
    
    func lines(withAxis axis: Line.Axis) -> [Line] {
        switch axis {
        case .horizontal:
            return horizontalLines
        case .vertical:
            return verticalLines
        }
    }
    
    convenience init(values: [[Int]]) {
        let cells = values.map {
            $0.map { value in
                Cell.validValues.contains(value) ? Cell(value: value, isPredefined: true) : Cell()
            }
        }
        self.init(cells: cells)
    }
    
    
    required init(cells: [[Cell]]) {
        // Setup the horizontal lines
        self.cells = cells
        initGroups()
    }
    
    func initGroups() {
        for line in cells {
            let horizontalLine = Line(.horizontal, cells: line)
            horizontalLines.append(horizontalLine)
            horizontalLine.remove(possibilities: horizontalLine.solvedValues)
        }
        
        // Setup the vertical lines
        for i in 0..<9 {
            let verticalCells = cells.map { $0[i] }
            let verticalLine = Line(.vertical, cells: verticalCells)
            verticalLines.append(verticalLine)
            verticalLine.remove(possibilities: verticalLine.solvedValues)
        }
        
        // Setup the squares
        for x in 0..<3 {
            for y in 0..<3 {
                var squareCells = [[Cell]]()
                for yOffset in 0..<3 {
                    squareCells.append(Array(cells[(y*3)+yOffset][x*3...(x*3+2)]))
                }
                let square = Square(arrangedCells: squareCells)
                squares.append(square)
                square.remove(possibilities: square.solvedValues)
            }
        }
    }
}

// MARK: - Puzzle+Equatable
extension Puzzle: Equatable {
    static func == (lhs: Puzzle, rhs: Puzzle) -> Bool {
        return lhs.id == rhs.id
            && lhs.cells == rhs.cells
    }
}

// MARK: - Access Control
extension Puzzle {
    func cell(at location: Location) -> Cell {
        self.cells[location.y][location.x]
    }
}

// MARK: - Puzzle Factory
extension Puzzle {
    static var new: Puzzle {
        var cells = [[Cell]]()
        for _ in 0..<9 {
            var line = [Cell]()
            for _ in 0..<9 {
                line.append(Cell())
            }
            cells.append(line)
        }
        return Puzzle(cells: cells)
    }
    
    static var mostlyFull: Puzzle {
        let values = [
            /* ========================= */
            [0,0,0,/*-*/4,0,6,/*-*/7,8,9,],
            [0,0,0,/*-*/7,8,9,/*-*/1,2,3,],
            [0,0,0,/*-*/1,2,3,/*-*/4,5,6,],
            /* ========================= */
            [9,1,2,/*-*/3,4,5,/*-*/6,7,8,],
            [3,4,5,/*-*/0,7,8,/*-*/9,1,2,],
            [6,7,8,/*-*/9,1,2,/*-*/3,4,5,],
            /* ========================= */
            [2,3,4,/*-*/5,6,7,/*-*/0,0,0,],
            [0,6,7,/*-*/8,9,1,/*-*/0,0,0,],
            [8,9,1,/*-*/2,3,4,/*-*/0,0,0,],
            /* ========================= */
        ]
        return Puzzle(values: values)
    }
}

// MARK: - Printing
extension Puzzle {
    private static let printDivider = "+---+---+---+"
    
    @discardableResult
    func print() -> String {
    
        var result = "\n"
        result.append(Self.printDivider)
        for i in 0..<horizontalLines.count {
            var printLine = "|"
            for j in 0..<3 {
                printLine.append(
                    horizontalLines[i].cells[(3*j)...(3*j)+2].reduce(into: "", { $0.append($1.printValue()) })
                )
                printLine.append("|")
            }
            result.append("\n")
            result.append(printLine)
            
            if i%3 == 2 {
                result.append("\n")
                result.append(Self.printDivider)
            }
        }
        Swift.print(result)
        return result
    }
}

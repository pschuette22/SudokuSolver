//
//  PuzzleTests.swift
//  SudokuHelperTests
//
//  Created by Peter Schuette on 7/31/21.
//

import XCTest
@testable import SudokuHelper

final class PuzzleTests: XCTestCase {

    func testPrint() {
        let expectedResult =
            """
            \n+---+---+---+
            |   |   |   |
            |   |   |   |
            |   |   |   |
            +---+---+---+
            |   |   |   |
            |   |   |   |
            |   |   |   |
            +---+---+---+
            |   |   |   |
            |   |   |   |
            |   |   |   |
            +---+---+---+
            """
        XCTAssertEqual(Puzzle.new.print(), expectedResult)
    }
    
    func testUniqueness() throws {
        let puzzle = Puzzle.new
        var groupCells = [UUID: Set<Cell>]()
        let cells = puzzle.cells.flatMap { $0 }
        
        try cells.forEach {
            let square = try XCTUnwrap($0.square)
            var squareSet = groupCells[square.id] ?? Set<Cell>()
            squareSet.insert($0)
            groupCells[square.id] = squareSet

            let vertical = try XCTUnwrap($0.verticalLine)
            var verticalSet = groupCells[vertical.id] ?? Set<Cell>()
            verticalSet.insert($0)
            groupCells[vertical.id] = verticalSet
            
            let horizontal = try XCTUnwrap($0.horizontalLine)
            var horizontalSet = groupCells[horizontal.id] ?? Set<Cell>()
            horizontalSet.insert($0)
            groupCells[horizontal.id] = horizontalSet
        }
        
        XCTAssertEqual(groupCells.count, 9 * 3)
        for (_, cells) in groupCells {
            XCTAssertEqual(cells.count, 9)
        }
    }
    
    
    func testInit() {
        
        let values = [
            /* ========================= */
            [1,2,3,/*-*/4,5,6,/*-*/7,8,9,],
            [4,5,6,/*-*/7,8,9,/*-*/1,2,3,],
            [7,8,9,/*-*/1,2,3,/*-*/4,5,6,],
            /* ========================= */
            [9,1,2,/*-*/3,4,5,/*-*/6,7,8,],
            [3,4,5,/*-*/6,7,8,/*-*/9,1,2,],
            [6,7,8,/*-*/9,1,2,/*-*/3,4,5,],
            /* ========================= */
            [2,3,4,/*-*/5,6,7,/*-*/8,9,1,],
            [5,6,7,/*-*/8,9,1,/*-*/2,3,4,],
            [8,9,1,/*-*/2,3,4,/*-*/5,6,7,],
            /* ========================= */
        ]
        
        let puzzle = Puzzle(values: values)
        
        for line in puzzle.horizontalLines {
            XCTAssertTrue(line.remainingValues.isEmpty)
        }
        
        for line in puzzle.verticalLines {
            XCTAssertTrue(line.remainingValues.isEmpty)
        }
        
        for square in puzzle.squares {
            XCTAssertTrue(square.remainingValues.isEmpty)
        }
    }
    
    func testExpectedPossibilities() {
        // remove's 5 and 1 from all groups intersecting 0,0
        let values = [
            /* ========================= */
            [0,2,3,/*-*/4,0,6,/*-*/7,8,9,],
            [4,0,6,/*-*/7,8,9,/*-*/1,2,3,],
            [7,8,9,/*-*/1,2,3,/*-*/4,5,6,],
            /* ========================= */
            [9,1,2,/*-*/3,4,5,/*-*/6,7,8,],
            [3,4,5,/*-*/0,7,8,/*-*/9,1,2,],
            [6,7,8,/*-*/9,1,2,/*-*/3,4,5,],
            /* ========================= */
            [2,3,4,/*-*/5,6,7,/*-*/8,9,1,],
            [0,6,7,/*-*/8,9,1,/*-*/2,3,4,],
            [8,9,1,/*-*/2,3,4,/*-*/5,6,7,],
            /* ========================= */
        ]
        
        let puzzle = Puzzle(values: values)
        puzzle.print()
        XCTAssertEqual(puzzle.cell(at: (x: 0, y: 0)).possibilities, Set<Int>([1,5]))
        XCTAssertEqual(puzzle.cell(at: (x: 4, y: 0)).possibilities, Set<Int>([5]))
        XCTAssertEqual(puzzle.cell(at: (x: 1, y: 1)).possibilities, Set<Int>([5]))
        XCTAssertEqual(puzzle.cell(at: (x: 0, y: 7)).possibilities, Set<Int>([5]))
        // Random one to make sure axis' are correct
        XCTAssertEqual(puzzle.cell(at: (x: 3, y: 4)).possibilities, Set<Int>([6]))
    }
}

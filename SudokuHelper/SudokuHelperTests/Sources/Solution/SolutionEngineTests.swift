//
//  SolutionEngineTests.swift
//  SudokuHelperTests
//
//  Created by Peter Schuette on 9/13/21.
//

import XCTest
@testable import SudokuHelper

final class SolutionEngineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExpertPuzzleSolve() {
        let puzzle = Puzzle(
            values: [
                [0,0,0,0,0,0,0,0,0],
                [0,4,1,6,0,0,0,8,0],
                [0,0,9,0,0,0,6,2,0],
                [4,0,0,0,6,0,0,1,0],
                [0,0,0,5,0,2,0,0,0],
                [0,0,0,0,9,0,0,0,2],
                [0,6,2,0,0,0,8,0,0],
                [0,5,0,0,0,6,1,7,0],
                [0,0,0,1,0,0,0,0,0],
            ]
        )
        
        let engine = SolutionEngine(puzzle: puzzle)
        engine.solve()
        XCTAssertTrue(puzzle.isSolved)
        
        puzzle.print()
    }
}

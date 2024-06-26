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
    
    // TODO: test individual moves
    

    func testExpertPuzzleSolve() {
        let puzzle = Puzzle(
            values: Self.expert5Values
        )
        let start = Date()
        let engine = SolutionEngine(puzzle: puzzle)
        engine.solve()
        let solvedIn = Date().timeIntervalSince(start)
        print("solved in \(solvedIn)")
        print(engine.history.reduce(into: Set<String>(), { $0.insert($1.strategy.rawValue)}))

        XCTAssertTrue(puzzle.isSolved)
        XCTAssertTrue(puzzle.isValid)

        puzzle.print()
    }
}

// MARK: - Solved in sibling tests
extension SolutionEngineTests {
    
    func testSolvedInSibling() {
        
    }
    
}


private extension SolutionEngineTests {
    
    static let template: [[Int]] = [
        [0,0,0,  0,0,0,  0,0,0],
        [0,0,0,  0,0,0,  0,0,0],
        [0,0,0,  0,0,0,  0,0,0],

        [0,0,0,  0,0,0,  0,0,0],
        [0,0,0,  0,0,0,  0,0,0],
        [0,0,0,  0,0,0,  0,0,0],

        [0,0,0,  0,0,0,  0,0,0],
        [0,0,0,  0,0,0,  0,0,0],
        [0,0,0,  0,0,0,  0,0,0],
    ]
    
    static let expert1Values: [[Int]] = [
        [0,0,0,  0,0,3,  0,0,0],
        [0,4,1,  6,0,0,  0,8,0],
        [0,0,9,  0,0,0,  6,2,0],
        
        [4,0,0,  0,6,0,  0,1,0],
        [0,0,0,  5,3,2,  0,0,0],
        [0,3,0,  0,9,0,  0,0,2],
        
        [0,6,2,  0,0,0,  8,0,0],
        [0,5,0,  0,0,6,  1,7,0],
        [0,0,0,  1,0,0,  0,0,0],
    ]
    
    static let expert2Values: [[Int]] = [
        [0,9,1,  0,7,0,  0,4,0],
        [2,0,4,  0,0,0,  0,0,0],
        [0,5,0,  3,0,0,  0,0,0],
        
        [1,0,0,  0,2,0,  0,0,8],
        [0,0,7,  6,0,3,  2,0,0],
        [9,0,0,  0,5,0,  0,0,3],
        
        [0,0,0,  0,0,7,  0,3,0],
        [0,0,0,  0,0,0,  9,0,6],
        [0,6,0,  0,1,0,  5,7,0],
    ]
    
    static let expert3Values: [[Int]] = [
        [8,0,0,  0,0,2,  0,0,3],
        [0,0,0,  7,0,0,  9,0,0],
        [9,0,0,  0,0,6,  0,4,0],
        
        [0,0,0,  0,1,0,  8,0,4],
        [0,0,6,  0,0,0,  5,0,0],
        [7,0,9,  0,8,0,  0,0,0],
        
        [0,3,0,  4,0,0,  0,0,6],
        [0,0,2,  0,0,7,  0,0,0],
        [6,0,0,  3,0,0,  0,0,5],
    ]
    
    static let expert4Values: [[Int]] = [
        [0,0,8,  0,0,0,  0,9,7],
        [0,2,0,  0,0,7,  0,0,0],
        [0,0,7,  0,0,2,  4,1,0],
        
        [7,0,0,  3,0,0,  0,2,0],
        [0,0,0,  6,0,5,  0,0,0],
        [0,3,0,  0,0,4,  0,0,6],

        [0,8,1,  5,0,0,  6,0,0],
        [0,0,0,  8,0,0,  0,3,0],
        [4,9,0,  0,0,0,  1,0,0],
    ]
    
    static let expert5Values: [[Int]] = [
        [9,0,0,  0,8,7,  0,0,0],
        [0,0,8,  0,0,0,  0,0,0],
        [2,3,0,  1,4,0,  0,0,7],

        [0,0,2,  9,5,0,  0,0,0],
        [6,0,0,  0,0,0,  0,0,2],
        [0,0,0,  0,7,4,  9,0,0],

        [3,0,0,  0,6,5,  0,2,4],
        [0,0,0,  0,0,0,  5,0,0],
        [0,0,0,  3,9,0,  0,0,8],
    ]
    
}

//
//  Array+ExtensionsTests.swift
//  SudokuHelperTests
//
//  Created by Peter Schuette on 8/7/21.
//

import XCTest
@testable import SudokuHelper

final class Array_ExtensionsTests: XCTestCase {

}

extension Array_ExtensionsTests {
    
    func testPermutations() {
        let array = [1,2,3,4]
        let combinations = array.permutations(ofSize: 3)
        let expectedCombinations = [
            [1, 2, 3],
            [1, 2, 4],
            [1, 3, 2],
            [1, 3, 4],
            [1, 4, 2],
            [1, 4, 3],
            [2, 1, 3],
            [2, 1, 4],
            [2, 3, 1],
            [2, 3, 4],
            [2, 4, 1],
            [2, 4, 3],
            [3, 1, 2],
            [3, 1, 4],
            [3, 2, 1],
            [3, 2, 4],
            [3, 4, 1],
            [3, 4, 2],
            [4, 1, 2],
            [4, 1, 3],
            [4, 2, 1],
            [4, 2, 3],
            [4, 3, 1],
            [4, 3, 2],
        ]
        
        XCTAssertEqual(combinations, expectedCombinations)
    }
    
    func testCombinations_threeOfFour() {
        let array = [1,2,3,4]
        let combinations = array.combinations(ofSize: 3).set
        let expected = [
            [1, 2, 3],
            [1, 2, 4],
            [1, 3, 4],
            [2, 3, 4],
        ].set
        
        XCTAssertEqual(combinations, expected)
    }
    
    func testCombinations_twoOfFour() {
        let array = [1,2,3,4]
        let combinations = array.combinations(ofSize: 2).set
        let expected = [
            [1, 2],
            [1, 3],
            [1, 4],
            [2, 3],
            [2, 4],
            [3, 4],
        ].set
        
        XCTAssertEqual(combinations, expected)
    }
    
    func testCombinations_twoOfFour_containing1() {
        let array = [1,2,3,4]
        let combinations = array.combinations(ofSize: 2, where: { $0.contains(1) }).set
        let expected = [
            [1, 2],
            [1, 3],
            [1, 4],
//          [2, 3], // These
//          [2, 4], // should be
//          [3, 4], // excluded
        ].set
        
        XCTAssertEqual(combinations, expected)
    }
    
    func testCombinationsCount_ofNineItems() {
        let array = [1,2,3,4,5,6,7,8,9]
        let size = 5
        let combinationCount = array.combinations(ofSize: size).count
        let numerator = (0..<size).reduce(1) { $0 * (array.count-$1) }
        let denominator = (1...size).reduce(1) { $0 * $1 }
        let expectedCount = numerator / denominator
        XCTAssertEqual(combinationCount, expectedCount)
    }
}



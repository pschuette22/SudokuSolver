//
//  SudokuParserTaskTests.swift
//  SudokuHelperTests
//
//  Created by Peter Schuette on 4/6/22.
//

import XCTest
@testable import SudokuHelper

class SudokuParserTaskTests: XCTestCase {
    private var testBundle: Bundle {
        Bundle(for: type(of: self))
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExecute_withSuccess() throws {
        let imageURL = try XCTUnwrap(testBundle.path(forResource: "Sudoku1Cropped", ofType: "jpg"))
        let image = try XCTUnwrap(UIImage(contentsOfFile: imageURL)?.cgImage)
        
        let expectation = XCTestExpectation(description: "The sudoku will be parsed")
        let delegate = MockSudokuParserTaskDelegate(expectation: expectation)
        
        let task = SudokuParserTask(delegate: delegate, responseQueue: .main, image: image)
        task.execute()
        
        wait(for: [expectation], timeout: .seconds(3))
        
        let result = try XCTUnwrap(delegate.result)
        switch result {
        case let .success(sudoku):
            let expected: [[Int]] = [
                [9,0,0,0,0,0,8,0,0],
                [0,2,0,0,5,6,7,0,0],
                [0,0,0,4,0,0,3,0,0],
                [0,0,0,3,2,7,0,0,0],
                [0,0,0,0,6,0,0,0,0],
                [0,0,8,0,0,5,0,0,4],
                [7,0,0,0,0,0,0,0,5],
                [3,6,0,0,1,0,0,0,8],
                [0,0,9,0,0,0,0,6,0],
            ]
            XCTAssertEqual(sudoku, expected)
        case let .failure(error):
            XCTFail(error.localizedDescription)
        }
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    // TODO: performance testing
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
}

private extension SudokuParserTaskTests {
    class MockSudokuParserTaskDelegate: SudokuParserTaskDelegate {
        var result: Result<[[Int]], Error>?
        let expectation: XCTestExpectation
        
        init(expectation: XCTestExpectation) {
            self.expectation = expectation
        }
        
        func sudokuParserTask(_ task: SudokuParserTask, didChangeState newState: SudokuParserTask.State) {
            print("did change state: \(newState)")
        }
        
        func sudokuParserTask(_ task: SudokuParserTask, didParse sudoku: [[Int]]) {
            self.result = .success(sudoku)
            expectation.fulfill()
        }
        
        func sudokuParserTask(_ task: SudokuParserTask, failedToParseSudokuWithError error: SudokuParsingError?) {
            self.result = .failure(error ?? NSError())
            expectation.fulfill()
        }
    }
}

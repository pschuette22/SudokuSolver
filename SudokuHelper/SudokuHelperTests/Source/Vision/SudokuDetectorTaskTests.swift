//
//  SudokuDetectorTaskTests.swift
//  SudokuHelperTests
//
//  Created by Peter Schuette on 4/6/22.
//

import XCTest
@testable import SudokuHelper

final class SudokuDetectorTaskTests: XCTestCase {
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
        let imageURL = try XCTUnwrap(testBundle.path(forResource: "Sudoku1", ofType: "jpg"))
        let image = try XCTUnwrap(UIImage(contentsOfFile: imageURL)?.cgImage)

        let expectation = XCTestExpectation(description: "The sudoku will be detected")
        let delegate = MockSudokuDetectorTaskDelegate(expectation: expectation)
        let task = SudokuDetectorTask(
            delegate: delegate,
            image: image,
            responseQueue: .main
        )
        task.execute()
        
        wait(for: [expectation], timeout: .seconds(3))
        
        let result = try XCTUnwrap(delegate.result)
        
        switch result {
        case let .success((location, confidence)):
            print(location)
            XCTAssert(true)
            XCTAssertGreaterThan(confidence, 0.9)
        case let .failure(error):
            XCTFail(error.localizedDescription)
        }
    }
}

// MARK: - MockSudokuDetectorTaskDelegate

private extension SudokuDetectorTaskTests {
    class MockSudokuDetectorTaskDelegate: SudokuDetectorTaskDelegate {
        let expectation: XCTestExpectation
        var result: Result<(CGRect, CGFloat), Error>?
        
        init(expectation: XCTestExpectation) {
            self.expectation = expectation
        }
        
        func sudokuDetectorTask(_ task: SudokuDetectorTask, didDetectSudokuIn image: CGImage, at location: CGRect, withConfidence confidence: CGFloat) {
            result = .success((location, confidence))
            expectation.fulfill()
        }
        
        func sudokuDetectorTask(_ task: SudokuDetectorTask, failedToDetectSudokuWithError error: Error) {
            result = .failure(error)
            expectation.fulfill()
        }
    }
}

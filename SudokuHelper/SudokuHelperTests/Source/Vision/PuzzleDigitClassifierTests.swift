//
//  PuzzleDigitClassifierTests.swift
//  SudokuHelperTests
//
//  Created by Peter Schuette on 3/25/22.
//

@testable import SudokuHelper
import UIKit
import XCTest

final class PuzzleDigitClassifierTests: XCTestCase {
    private var testBundle: Bundle {
        Bundle(for: type(of: self))
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testClassifyingImage_1Slice() throws {
        try testImageSlice(of: 1)
    }
    
    func testClassifyingImage_2Slice() throws {
        try testImageSlice(of: 2)
    }
    
    func testClassifyingImage_3Slice() throws {
        try testImageSlice(of: 3)
    }
    
    func testClassifyingImage_4Slice() throws {
        try testImageSlice(of: 4)
    }
    
    func testClassifyingImage_5Slice() throws {
        try testImageSlice(of: 5)
    }
    
    func testClassifyingImage_6Slice() throws {
        try testImageSlice(of: 6)
    }
    
    func testClassifyingImage_7Slice() throws {
        try testImageSlice(of: 7)
    }
    
    func testClassifyingImage_8Slice() throws {
        try testImageSlice(of: 8)
    }
    
    // TODO: test slice of 9

    
    private func testImageSlice(of testDigit: Int) throws {
        let imageURL = try XCTUnwrap(testBundle.path(forResource: "imageSlice_\(testDigit)", ofType: "jpg"))
        let image = try XCTUnwrap(UIImage(contentsOfFile: imageURL))
        let classifier = PuzzleDigitClassifier()
        let expectation = XCTestExpectation(description: "The digit will be classified")
        classifier.classifyDigit(in: image) { result in
            switch result {
            case .success(let digit):
                XCTAssertEqual(digit, testDigit)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: .seconds(3))
    }
    
}

//
//  DetectorViewControllerState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/24/21.
//

import Foundation
import CoreGraphics
import UIKit

struct DetectorViewControllerState: ViewState {
    struct LocatedCell: Hashable {
        enum CellType: Hashable {
            case filled(Int?)
            case empty
            case solved(Int)
            case error
            case unknown
            
            init(from label: String?) {
                switch label {
                case "empty"?:
                    self = .empty
                case "filled"?:
                    self = .filled(nil)
                default:
                    self = .unknown
                }
            }
        }
        let frame: CGRect
        let type: CellType
        var value: Int? {
            switch type {
            case .filled(let value):
                return value
            case .solved(let value):
                return value
            case .empty, .error, .unknown:
                return nil
            }
        }
    }
    
    enum Context: Hashable {
        case detecting
        case detectedSudoku(
            image: CGImage,
            imageSize: CGSize,
            frameInImage: CGRect,
            confidence: CGFloat
        )
        case parsingSudoku(
            image: CGImage
        )
        case locatedCells(
            image: CGImage,
            cells: [LocatedCell]
        )
        case parsedSudoku(
            image: CGImage,
            imageSize: CGSize,
            cells: [[LocatedCell]]
        )
        case solvedSudoku(
            image: CGImage,
            imageSize: CGSize,
            cells: [[LocatedCell]]
        )
    }
    private(set) var context: Context
    
    init(
        context: Context = .detecting
    ) {
        self.context = context
    }
}

// MARK: - Queries
extension DetectorViewControllerState {
    var isPreviewLayerDisplayed: Bool {
        switch context {
        case .detecting, .detectedSudoku:
            return true
        
        case .parsingSudoku, .locatedCells, .parsedSudoku, .solvedSudoku:
            return false
        }
    }
    
    var isParsingViewDisplayed: Bool {
        switch context {
        case .detecting, .detectedSudoku, .solvedSudoku:
            return false
            
        case .parsingSudoku, .locatedCells, .parsedSudoku:
            return true
        }
    }
    
    var isCaptureButtonHidden: Bool {
        switch context {
        case .detectedSudoku(_, _, _, let confidence):
            return confidence < 0.8 // 80% or greater confidence and we defer to user

        case .detecting,
             .parsingSudoku,
             .locatedCells,
             .parsedSudoku,
             .solvedSudoku:
            return true
        }
    }
    
    var captureButtonAlpha: CGFloat {
        switch context {
        case .detectedSudoku(_, _, _, let confidence):
            return confidence

        case .detecting,
             .parsingSudoku,
             .locatedCells,
             .parsedSudoku,
             .solvedSudoku:
            return 0
        }
    }
    
    var captureButtonText: String {
        guard case .detectedSudoku(_, _, _, let confidence) = context else { return "" }
        let percent = Int(confidence * 100)
        return "Capture (\(percent)% confident)"
    }
}

// MARK: - Mutations

extension DetectorViewControllerState {
    mutating
    func toDetecting() {
        self.context = .detecting
    }
    
    mutating
    func toDetectedSudoku(in image: CGImage, withSize imageSize: CGSize, frameInImage frame: CGRect, confidence: CGFloat) {
        self.context = .detectedSudoku(image: image, imageSize: imageSize, frameInImage: frame, confidence: confidence)
    }
    
    mutating
    func toParsingSudoku(in image: CGImage) {
        self.context = .parsingSudoku(image: image)
    }
    
    mutating
    func toLocatedCells(in image: CGImage, cells: [LocatedCell]) {
        self.context = .locatedCells(image: image, cells: cells)
    }
    
    mutating
    func toParsedSudoku(in image: CGImage, withSize imageSize: CGSize, locatedCells: [[LocatedCell]]) {
        self.context = .parsedSudoku(image: image, imageSize: imageSize, cells: locatedCells)
    }
    
    mutating
    func toSolvedSudoku(in image: CGImage, withSize imageSize: CGSize, locatedCells: [[LocatedCell]]) {
        self.context = .solvedSudoku(image: image, imageSize: imageSize, cells: locatedCells)
    }
}

// MARK: - CGRect+Hashable

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine("x:\(origin.x)")
        hasher.combine("y:\(origin.y)")
        hasher.combine(size.hashValue)
    }
}

// MARK: - CGSize+Hashable

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine("w:\(width)")
        hasher.combine("h:\(height)")
    }
}

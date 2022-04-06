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
            case filled
            case empty
            case unknown
            
            init(from label: String?) {
                switch label {
                case "empty"?:
                    self = .empty
                case "filled"?:
                    self = .filled
                default:
                    self = .unknown
                }
            }
        }
        let frame: CGRect
        let type: CellType
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
            cells: [[CGRect]],
            values: [[Int]]
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
        
        case .parsingSudoku, .locatedCells, .parsedSudoku:
            return false
        }
    }
    
    var isParsingViewDisplayed: Bool {
        switch context {
        case .detecting, .detectedSudoku:
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
             .parsedSudoku:
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
             .parsedSudoku:
            return 0
        }
    }
    
    var captureButtonText: String {
        guard case .detectedSudoku(_, _, _, let confidence) = context else { return "" }
        return "Capture - \(Int(confidence * 100))% confidence"
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
    func toParsedSudoku(in image: CGImage, withSize imageSize: CGSize, cellFrames: [[CGRect]], values: [[Int]]) {
        self.context = .parsedSudoku(image: image, imageSize: imageSize, cells: cellFrames, values: values)
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

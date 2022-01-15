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
    enum Context: Hashable {
        case detecting
        case detectedSudoku(
            image: CGImage,
            imageSize: CGSize,
            frameInImage: CGRect,
            confidence: Float
        )
        case parsingSudoku(
            image: CGImage
        )
        // case parsedSudoku(image, imageSize, cells, values)
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
        
        case .parsingSudoku:
            return false
        }
    }
    
    var isParsingViewDisplayed: Bool {
        switch context {
        case .detecting, .detectedSudoku:
            return false
            
        case .parsingSudoku:
            return true
        }
    }
}

// MARK: - Mutations

extension DetectorViewControllerState {
    mutating
    func toDetecting() {
        self.context = .detecting
    }
    
    mutating
    func toDetectedSudoku(in image: CGImage, withSize imageSize: CGSize, frameInImage frame: CGRect, confidence: Float) {
        self.context = .detectedSudoku(image: image, imageSize: imageSize, frameInImage: frame, confidence: confidence)
    }
    
    mutating
    func toParsingSudoku(in image: CGImage) {
        self.context = .parsingSudoku(image: image)
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

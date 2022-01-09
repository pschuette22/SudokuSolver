//
//  DetectorViewControllerState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/24/21.
//

import Foundation
import CoreGraphics

struct DetectorViewControllerState: ViewState {
    enum Context: Hashable {
        case detecting
        case detectedSudoku(
            image: CGImage,
            imageSize: CGSize,
            frameInImage: CGRect,
            confidence: Float
        )
        // case parsingSudoku
        // case 
    }
    private(set) var context: Context
    
    init(
        context: Context = .detecting
    ) {
        self.context = context
    }
}

extension DetectorViewControllerState {
    
    mutating
    func toDetecting() {
        self.context = .detecting
    }
    
    mutating
    func toDetectedSudoku(in image: CGImage, withSize imageSize: CGSize, frameInImage frame: CGRect, confidence: Float) {
        self.context = .detectedSudoku(image: image, imageSize: imageSize, frameInImage: frame, confidence: confidence)
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

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine("width:\(width)")
        hasher.combine("height:\(height)")
    }
}

//
//  DetectorViewControllerModel.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/24/21.
//

import Foundation
import CoreML
import Vision
import CoreGraphics
import UIKit

final class DetectorViewControllerModel: ViewModel<DetectorViewControllerState> {
    private let requiredConfidence: CGFloat
    private let sudokuImageParser: SudokuImageParser
    
    init(
        initialState state: DetectorViewControllerState = .init(),
        requiredConfidence: CGFloat = 0.95,
        sudokuImageParser: SudokuImageParser = .init()
    ) {
        self.requiredConfidence = requiredConfidence
        self.sudokuImageParser = sudokuImageParser

        super.init(initialState: state)
        
        sudokuImageParser.delegate = self
        
    }
}

extension DetectorViewControllerModel: SudokuImageParserDelegate {
    func sudokuImageParser(_ parser: SudokuImageParser, didChangeState newState: SudokuImageParser.State) {
        switch newState {
        case .idle,
             .searching:
            update { state in
                state.toDetecting()
            }
            
        case let .parsingCells(visionObject):
            update { state in
                state.toParsingSudoku(in: visionObject.slice)
            }
            
        case let .classifyingCells(image, visionObjects):
            let locatedCells: [DetectorViewControllerState.LocatedCell] = visionObjects.map {
                // TODO: determine how filled/empty is denoted
                let type = DetectorViewControllerState.LocatedCell.CellType(from: $0.label)
                return DetectorViewControllerState.LocatedCell(frame: $0.location, type: type)
            }

            update { state in
                state.toLocatedCells(in: image, cells: locatedCells)
            }

        case .parsed(_):
            print("we parsed it!")
        }
    }
    
    func didDetectSudoku(in object: VisionRequestObject) {
        update { state in
            state.toDetectedSudoku(
                in: object.slice,
                withSize: object.originalImageSize,
                frameInImage: object.location,
                confidence: object.confidence
            )
        }
    }
    
    func shouldParseSudokuCells(_ object: VisionRequestObject) -> Bool {
        return object.confidence >= requiredConfidence
    }
    
    func failedToParseSudoku(_ error: SudokuParsingError?) {
        if let error = error {
            Logger.log(error: error)
        }
    }
}

// MARK: - Capture Session lifecycle
extension DetectorViewControllerModel {
    func didStartCaptureSession() {
        
    }
    
    func didEndCaptureSession() {
        
    }
    
    func didFailToSetupCaptureSession(_ error: Error? = nil) {
        // TODO: State to error state
        Logger.log(.error, message: "Failed to setup capture session", params: ["error": error?.localizedDescription ?? "<nil>"])
    }
    
    func didFailToStartCaptureSession(_ error: Error) {
        Logger.log(.error, message: "Failed to start capture session", params: ["error": error])
    }
    
}

// MARK: - ML Integrations

extension DetectorViewControllerModel {
    func didNotDetectSudoku() {
        update {
            $0.toDetecting()
        }
    }
    
    func findSudoku(
        in image: CGImage,
        bufferSize: CGSize,
        dispatchTo dispatchQueue: DispatchQueue = .main
    ) {
        sudokuImageParser.parseSudoku(from: image)
    }
}

// MARK: - Image Parsing

extension DetectorViewControllerModel {
    func parseSudoku(in image: CGImage, ofSize size: CGSize, withFrame frame: CGRect) {
        guard case .detectedSudoku = state.context else { return }
        
        guard
            let croppedImage = image.cropping(to: frame)
        else {
            update { $0.toDetecting() }
            return
        }

        update {
            $0.toParsingSudoku(in: croppedImage)
        }
        
    }
}


// MARK: - CGRect+CustomStringConvertible

extension CGRect: CustomStringConvertible {
    public var description: String {
        "x:\(origin.x),y:\(origin.y),h:\(height),w:\(width)"
    }
}

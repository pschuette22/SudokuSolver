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
    private var sudokuDetectorTasks = Set<SudokuDetectorTask>()
    private var sudokuParserTask: SudokuParserTask?
    private var detectionStack = Stack<(image: CGImage, expires: Date, location: CGRect, confidence: CGFloat)>()
    private static let validDetectionInterval: TimeInterval = .milliseconds(250)
    
    override init(
        initialState state: DetectorViewControllerState = .init()
    ) {
        super.init(initialState: state)
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
    func findSudoku(
        in image: CGImage
    ) {
        let task = SudokuDetectorTask(
            delegate: self,
            image: image,
            responseQueue: DispatchQueue.main
        )
        sudokuDetectorTasks.insert(task)
        task.execute()
    }
    
    func didTapCaptureButton() {
        guard
            let detectionData = detectionStack.peek(),
            detectionData.confidence > 0.8,
            let croppedPuzzle = detectionData.image.cropping(to: detectionData.location)
            // TODO: assert we are not currently parsing the sudoku
        else {
            return
        }

        update { state in
            state.toParsingSudoku(in: detectionData.image)
        }
        
        
        sudokuParserTask = SudokuParserTask(
            delegate: self,
            image: croppedPuzzle
        )

        sudokuParserTask?.execute()
    }
}

// MARK: - SudokuDetectorTaskDelegate

extension DetectorViewControllerModel: SudokuDetectorTaskDelegate {
    func sudokuDetectorTask(
        _ task: SudokuDetectorTask,
        didDetectSudokuIn image: CGImage,
        at location: CGRect,
        withConfidence confidence: CGFloat
    ) {
        sudokuDetectorTasks.remove(task)
        // Keep the detected sudoku valid for half a second
        detectionStack.push((image, Current.date().addingTimeInterval(Self.validDetectionInterval), location, confidence))
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.validDetectionInterval) { [weak self] in
            while
                let expires = self?.detectionStack.peekLast()?.expires,
                expires < Current.date()
            {
                self?.detectionStack.dropLast()
            }
        }

        let originalImageSize = CGSize(width: task.image.width, height: task.image.height)
        update { state in
            state.toDetectedSudoku(
                in: image,
                withSize: originalImageSize,
                frameInImage: location,
                confidence: confidence
            )
        }
    }
    
    func sudokuDetectorTask(_ task: SudokuDetectorTask, failedToDetectSudokuWithError error: Error) {
        sudokuDetectorTasks.remove(task)
        Logger.log(error: error)
        if
            let visionError = error as? SudokuDetectorTask.DetectError,
            case .didntFindSudoku = visionError
        {
            // If there is a failure interval, clear all cached detections
            detectionStack.clear()
        }
    }
}

// MARK: - SudokuImageParserDelegate

extension DetectorViewControllerModel: SudokuParserTaskDelegate {
    func sudokuParserTask(_ task: SudokuParserTask, didChangeState newState: SudokuParserTask.State) {
        guard task == sudokuParserTask else { return }

        switch newState {
        case .idle:
            update { state in
                state.toDetecting()
            }
        case .parsingCells:
            update { state in
                state.toParsingSudoku(in: task.image)
            }
        case .classifyingCells(let visionObjects):

            // TODO: hide vision objects into task implementation
            // Might need to handle normalizing
            let locatedCells: [DetectorViewControllerState.LocatedCell] = visionObjects.map {
                let type = DetectorViewControllerState.LocatedCell.CellType(from: $0.label)
                return DetectorViewControllerState.LocatedCell(frame: $0.location, type: type)
            }

            update { state in
                // TODO: cell locations
                state.toLocatedCells(in: task.image, cells: locatedCells)
            }
        case .parsed(let puzzleDigits):
            update { state in
                // TODO: puzzle size, cell frames
                state.toParsedSudoku(
                    in: task.image,
                    withSize: .zero,
                    cellFrames: [],
                    values: puzzleDigits
                )
            }
        }
    }
    
    func sudokuParserTask(_ task: SudokuParserTask, didParse sudoku: [[Int]]) {
        guard task == sudokuParserTask else { return }

        // TODO: Determine if I want to go this route or state changes
        // Leaning towards this route
    }
    
    func sudokuParserTask(_ task: SudokuParserTask, failedToParseSudokuWithError error: SudokuParsingError?) {
        guard task == sudokuParserTask else { return }

        // TODO: Determine if I want to go this route or state changes
    }
//    func didDetectSudoku(in object: VisionRequestObject) {
//        update { state in
//            state.toDetectedSudoku(
//                in: object.slice,
//                withSize: object.originalImageSize,
//                frameInImage: object.location,
//                confidence: object.confidence
//            )
//        }
//    }
//
//    func failedToParseSudoku(_ error: SudokuParsingError?) {
//        if let error = error {
//            Logger.log(error: error)
//        }
//
//        update { state in
//            state.toDetecting()
//        }
//    }
}

// MARK: - Image Parsing

extension DetectorViewControllerModel {
//    func parseSudoku(in image: CGImage, ofSize size: CGSize, withFrame frame: CGRect) {
//        guard case .detectedSudoku = state.context else { return }
//
//        guard
//            let croppedImage = image.cropping(to: frame)
//        else {
//            update { $0.toDetecting() }
//            return
//        }
//
//        update {
//            $0.toParsingSudoku(in: croppedImage)
//        }
//
//    }
}


// MARK: - CGRect+CustomStringConvertible

extension CGRect: CustomStringConvertible {
    public var description: String {
        "x:\(origin.x),y:\(origin.y),h:\(height),w:\(width)"
    }
}

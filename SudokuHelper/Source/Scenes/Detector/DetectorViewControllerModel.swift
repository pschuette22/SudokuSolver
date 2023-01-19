//
//  DetectorViewControllerModel.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/24/21.
//

import Combine
import Foundation
import CoreML
import Vision
import CoreGraphics
import UIKit

final class DetectorViewControllerModel: ViewModel<DetectorViewControllerState> {
    enum Context: Equatable {
        case solveInPlace
        case retrieveValues
        case demoMode
    }
    
    // Demo state?
    private enum DemoState {
        case captured(image: CGImage)
        case parsed
        case solved(image: CGImage, puzzleDigits: [[(Int, CGRect, SudokuParserTask.CellType)]])
        case restart
        
        var isInParsedState: Bool {
            switch self {
            case .parsed:
                return true
            default:
                return false
            }
        }
        
        var isSolved: Bool {
            switch self {
            case .solved:
                return true
            default:
                return false
            }
        }
    }

    enum Action: Equatable {
        case didScan(values: [[Int?]])
        case error
    }

    private(set) lazy var action: AnyPublisher<Action, Never> = actionSubject.eraseToAnyPublisher()
    private let actionSubject =  PassthroughSubject<Action, Never>()
    private let context: Context
    private var isInDemoMode: Bool { context == .demoMode }
    private var demoState: DemoState?
    private var sudokuDetectorTasks = Set<SudokuDetectorTask>()
    private var sudokuParserTask: SudokuParserTask?
    private var detectionStack = [(image: CGImage, expires: Date, location: CGRect, confidence: CGFloat)]()
    private static let validDetectionInterval: TimeInterval = .milliseconds(100)
    
    required init(
        context: Context = .solveInPlace,
        initialState state: DetectorViewControllerState = .init()
    ) {
        self.context = context
        super.init(initialState: state)
    }
}

extension DetectorViewControllerModel {
    func didTapTryAgainAfterFailure() {
        demoState = nil
        update {
            $0.demoButtonText = nil
            $0.toDetecting()
        }
    }
}

// MARK: - Capture Session lifecycle
extension DetectorViewControllerModel {
    func didStartCaptureSession() { }
    
    func didEndCaptureSession() { }
    
    func didFailToSetupCaptureSession(_ error: Error? = nil) {
        // TODO: State to error state
        Logger.log(.error, message: "Failed to setup capture session", params: ["error": error?.localizedDescription ?? "<nil>"])
    }
    
    func didFailToStartCaptureSession(_ error: Error) {
        Logger.log(.error, message: "Failed to start capture session", params: ["error": error])
    }
    
}

// MARK: - Interface Methods

extension DetectorViewControllerModel {
    func findSudoku(
        in image: CGImage
    ) {
        guard sudokuDetectorTasks.count < 5 else { return }
        let task = SudokuDetectorTask(
            delegate: self,
            image: image,
            responseQueue: DispatchQueue.main
        )
        sudokuDetectorTasks.insert(task)
        task.execute()
    }
    
    func didTapCaptureButton() {
        if isInDemoMode, let demoState {
            switch demoState {
            case .captured(let puzzleImage):
                executeParserTask(in: puzzleImage)
            case .parsed:
                break
            case let .solved(image, puzzleDigits):
                presentSolution(image: image, puzzleDigits: puzzleDigits)
            case .restart:
                self.demoState = nil
                update {
                    $0.demoButtonText = nil
                    $0.toDetecting()
                }
            }
        } else {
            guard
                let detectionData = detectionStack.first,
                detectionData.confidence > 0.8,
                let croppedPuzzle = detectionData.image.cropping(to: detectionData.location)
                // TODO: assert we are not currently parsing the sudoku
            else {
                return
            }

            update { state in
                state.toParsingSudoku(in: detectionData.image)
            }
            
            if isInDemoMode {
                demoState = .captured(image: croppedPuzzle)
                update { state in
                    state.demoButtonText = "Parse Sudoku"
                    
                }
            } else {
                executeParserTask(in: croppedPuzzle)
            }
        }
    }
    
    private func captureImage() {
        guard
            let detectionData = detectionStack.first,
            detectionData.confidence > 0.8,
            let croppedPuzzle = detectionData.image.cropping(to: detectionData.location)
            // TODO: assert we are not currently parsing the sudoku
        else {
            return
        }

        update { state in
            state.toParsingSudoku(in: detectionData.image)
        }
        
        if isInDemoMode {
            demoState = .captured(image: croppedPuzzle)
            update { state in
                state.demoButtonText = "Parse Sudoku"
                
            }
        } else {
            executeParserTask(in: croppedPuzzle)
        }
    }
    
    
    func executeParserTask(in image: CGImage) {
        sudokuParserTask = SudokuParserTask(
            delegate: self,
            image: image
        )
        
        sudokuParserTask?.execute()
    }
    
    private func solveSudoku(in image: CGImage, with cells: [[DetectorViewControllerState.LocatedCell]]) {
        // TODO: consider pausing here and waiting for continue command
        
        let digits: [[Int]] = cells.map { row in
            return row.map { cell in
                switch cell.type {
                case .unknown, .empty, .error:
                    return 0
                case let .filled(value):
                    return value ?? 0
                case let .solved(value):
                    return value
                }
            }
        }
        let puzzle = Puzzle(values: digits)
        puzzle.print()

        do {
            let didSolve = try SolutionEngine(puzzle: puzzle).solve()
            if didSolve {
                var cells = cells
                cells.enumerated().forEach { y, row in
                    row.enumerated().forEach { x, cell in
                        guard let value = puzzle.valueAt(x: x, y: y) else {
                            cells[y][x] = .init(frame: cells[y][x].frame, type: .empty)
                            return
                        }

                        if case .empty = cells[y][x].type {
                            cells[y][x] = .init(frame: cells[y][x].frame, type: .solved(value))
                        }
                    }
                }
                
                update { state in
                    state.toSolvedSudoku(in: image, withSize: .zero, locatedCells: cells)
                }
                
                puzzle.print()
                
            } else {
                update { state in
                    state.toDetecting()
                }
            }
        } catch let error {
            handle(solveError: error)
        }
    }
    
    private func handle(solveError: Error) {
        update {
            $0.toFailedToFindSolution()
        }
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
        if detectionStack.isEmpty {
            detectionStack.append((image, Current.date().addingTimeInterval(Self.validDetectionInterval), location, confidence))
        } else {
            detectionStack.insert((image, Current.date().addingTimeInterval(Self.validDetectionInterval), location, confidence), at: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.validDetectionInterval) { [weak self] in
            while
                let expires = self?.detectionStack.last?.expires,
                expires <= Current.date()
            {
                self?.detectionStack.removeLast()
            }
        }
        let removeAmount = detectionStack.count - 5
        if removeAmount > 0 {
            detectionStack.removeLast(detectionStack.count - 5)
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
            detectionStack.removeAll()
        }
        
        update { state in
            state.toDetecting()
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

            demoState = .parsed
            
            update { [weak self] state in
                if self?.isInDemoMode == true {
                    state.demoButtonText = "Solve Puzzle"
                }
                state.toLocatedCells(in: task.image, cells: locatedCells)
            }

        case .parsed(let puzzleDigits):
            let cells: [[DetectorViewControllerState.LocatedCell]] = puzzleDigits.map { row in
                return row.map { cellData in
                    switch cellData.2 {
                    case .provided:
                        return .init(frame: cellData.1, type: .filled(cellData.0))
                    case .empty:
                        return .init(frame: cellData.1, type: .empty)
                    case .unknown, .error:
                        return .init(frame: cellData.1, type: .error)
                    }
                }
            }
            
            switch context {
            case .solveInPlace:
                presentSolution(image: task.image, puzzleDigits: puzzleDigits)
            case .retrieveValues:
                let mappedValues = cells.map { $0.map { $0.value }}
                actionSubject.send(.didScan(values: mappedValues))
            case .demoMode:
                demoState = .solved(image: task.image, puzzleDigits: puzzleDigits)
                break
            }
        }
    }
    
    private func presentSolution(image: CGImage, puzzleDigits: [[(Int, CGRect, SudokuParserTask.CellType)]]) {
        let cells: [[DetectorViewControllerState.LocatedCell]] = puzzleDigits.map { row in
            return row.map { cellData in
                switch cellData.2 {
                case .provided:
                    return .init(frame: cellData.1, type: .filled(cellData.0))
                case .empty:
                    return .init(frame: cellData.1, type: .empty)
                case .unknown, .error:
                    return .init(frame: cellData.1, type: .error)
                }
            }
        }
        
        update { [weak self] state in
            state.toParsedSudoku(
                in: image,
                withSize: .zero,
                locatedCells: cells
            )
            if self?.isInDemoMode == true {
                state.demoButtonText = "restart"
            }
        }
        solveSudoku(in: image, with: cells)
        
        if isInDemoMode {
            demoState = .restart
        }
    }
    
    func sudokuParserTask(_ task: SudokuParserTask, didParse sudoku: [[(Int, CGRect, SudokuParserTask.CellType)]]) {
        guard task == sudokuParserTask else { return }

        // TODO: Determine if I want to go this route or state changes
        // Leaning towards this route
    }
    
    func sudokuParserTask(_ task: SudokuParserTask, failedToParseSudokuWithError error: SudokuParsingError?) {
        guard task == sudokuParserTask else { return }

        // TODO: Determine if I want to go this route or state changes
    }
}

// MARK: - CGRect+CustomStringConvertible

extension CGRect: CustomStringConvertible {
    public var description: String {
        "x:\(origin.x),y:\(origin.y),h:\(height),w:\(width)"
    }
}

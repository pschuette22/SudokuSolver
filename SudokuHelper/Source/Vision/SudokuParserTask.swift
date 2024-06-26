//
//  SudokuImageParser.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 2/19/22.
//

import Foundation
import Combine
import CoreGraphics
import CoreML
import Vision
import UIKit

protocol SudokuParserTaskDelegate: AnyObject {
    func sudokuParserTask(_ task: SudokuParserTask, didChangeState newState: SudokuParserTask.State)
    // Rather than dispatch state change, should we dispatch relevant changes?
    func sudokuParserTask(_ task: SudokuParserTask, didParse sudoku: [[(Int, CGRect, SudokuParserTask.CellType)]])
    func sudokuParserTask(_ task: SudokuParserTask, failedToParseSudokuWithError error: SudokuParsingError?)
}

/// Errors from parsing
enum SudokuParsingError: Error {
    case visionRequestInitFailed(Error)
    case visionRequestError(Error)
    case classificationFailed(Error)
    case invalidResponse
}

class SudokuParserTask {
    private let id = UUID()
    private static let parsingQueue = DispatchQueue(
        label: Bundle.main.bundleIdentifier ?? "" + ".SudokuParserTask",
        qos: .userInitiated
    )
    private static var parserModel: VNCoreMLModel?
    
    enum CellType {
        case unknown
        case provided
        case empty
        case error
    }
    
    enum State {
        case idle
        case parsingCells
        case classifyingCells(visionObjects: [VisionRequestObject])
        case parsed([[(Int, CGRect, CellType)]])
    }
    
    private(set) var state: State = .idle {
        didSet {
            DispatchQueue.main.async { [weak self, state] in
                guard let self = self else { return }
                
                self.delegate?.sudokuParserTask(self, didChangeState: state)
            }
        }
    }

    private var sudokuCellVisionRequest: VisionRequest?
    private var cellClassifierTask: CellClassifierTask?

    weak var delegate: SudokuParserTaskDelegate?
    private let responseQueue: DispatchQueue
    let image: CGImage
    
    init(
        delegate: SudokuParserTaskDelegate? = nil,
        responseQueue: DispatchQueue = .main,
        image: CGImage
    ) {
        self.delegate = delegate
        self.responseQueue = responseQueue
        self.image = image
    }
}

// MARK: =
extension SudokuParserTask: Hashable {
    static func == (lhs: SudokuParserTask, rhs: SudokuParserTask) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension SudokuParserTask {
    func execute() {
        Self.parsingQueue.async { [weak self] in
            guard
                let self = self,
                self.sudokuCellVisionRequest?.isRunning != true
            else {
                return
            }
            
            self.state = .parsingCells
            
            do {
                if Self.parserModel.isNil {
                    let modelConfig = MLModelConfiguration()
                    #if targetEnvironment(simulator)
                    modelConfig.computeUnits = .cpuOnly
                    #else
                    modelConfig.computeUnits = .all
                    #endif
                    let sudokuCellModel = try SudokuCellDetector(configuration: modelConfig)
                    Self.parserModel = try VNCoreMLModel(for: sudokuCellModel.model)
                }
                
                self.sudokuCellVisionRequest = .init(
                    modelName: "SudokuCellDetector",
                    model: Self.parserModel!,
                    image: self.image,
                    requiredConfidence: 0.6
                )
                
                
            } catch {
                self.state = .idle
                self.responseQueue.async {
                    self.delegate?.sudokuParserTask(self, failedToParseSudokuWithError: .visionRequestInitFailed(error))
                }
                return
            }
            
            self.sudokuCellVisionRequest?.execute(self.responseQueue) { [weak self] result in
                guard
                    let self = self
                else { return }
                
                let image = self.image
                
                defer {
                    self.sudokuCellVisionRequest = nil
                }
                
                switch result {
                case let .success(visionObjects):
                    Logger.log(.debug, message: "detected \(visionObjects.count) vision objects")

                    guard visionObjects.count == 81 else {
                        self.responseQueue.async {
                            self.delegate?.sudokuParserTask(self, failedToParseSudokuWithError: .visionRequestError(NSError()))
                        }
                        return
                    }
                    self.state = .classifyingCells(visionObjects: visionObjects)
                    let sortedObject = SudokuCellOrganizer.organize(sudokuCellObjects: visionObjects, foundIn: image)
                    self.cellClassifierTask = CellClassifierTask(cellVisionObjects: sortedObject)
                    
                    self.cellClassifierTask?.classifyCells(responseQueue: self.responseQueue) { result in
                        switch result {
                        case let .success(puzzleDigits):
                            #if DEBUG
                            print("Classified images:")
                            for row in puzzleDigits {
                                print(row.map({ $0.0 == 0 ? "_" : "\($0.0)" }).joined(separator: "."))
                            }
                            #endif
                            self.state = .parsed(puzzleDigits)
                            self.delegate?.sudokuParserTask(self, didParse: puzzleDigits)
                        case let .failure(error):
                            Logger.log(error: error)
                            self.delegate?.sudokuParserTask(self, failedToParseSudokuWithError: .classificationFailed(error))
                            self.state = .idle
                        }
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                    self.state = .idle
                }
            }
        }
    }
}

// MARK: - CellClassifierTask

private extension SudokuParserTask {
    class CellClassifierTask {
        private let group = DispatchGroup()
        private let cellVisionObjects: [[VisionRequestObject]]
        private var result: [[(Int, CGRect, CellType)]]
        private var errors = [VisionRequestObject: Error]()

        init(cellVisionObjects: [[VisionRequestObject]]) {
            self.cellVisionObjects = cellVisionObjects
            result = (0..<9).reduce(into: []) { result, y in
                var line = [(Int, CGRect, CellType)]()
                for item in cellVisionObjects[y] {
                    line.append((-1, item.location, .unknown))
                }
                result.append(line)
            }
        }
        
        func classifyCells(
            responseQueue: DispatchQueue,
            completion: @escaping (Result<[[(Int, CGRect, CellType)]], Error>) -> Void
        ) {
            cellVisionObjects.enumerated().forEach { y, objectRow in
                objectRow.enumerated().forEach { x, object in
                    
                    if object.label == "empty" {
                        self.result[y][x].0 = 0
                        self.result[y][x].2 = .empty
                        return
                    }
                    
                    let sliceImage = UIImage(cgImage: object.slice)

                    group.enter()

                    self.runDigitClassifier(on: sliceImage) { [weak self, object, group] result in
                        switch result {
                        case .success(let digit):
                            self?.result[y][x].0 = digit
                            self?.result[y][x].2 = .provided
                        case .failure(let error):
                            self?.result[y][x].2 = .error
                            self?.errors[object] = error
                            Logger.log(error: error)
                        }
                        group.leave()
                    }
                }
            }
            
            // Dispatch the classifying group
            group.notify(queue: responseQueue) { [weak self] in
                guard let self = self else { return }

                if self.errors.isEmpty {
                    completion(.success(self.result))
                } else {
                    completion(.failure(CellClassifierTaskError.classifying(self.errors, self.result)))
                }
            }
        }
        
        private func runDigitClassifier(on image: UIImage, completion: @escaping (Result<Int, Error>) -> Void) {
            PuzzleDigitClassifier().classifyDigit(in: image, completion)
        }
        
        enum CellClassifierTaskError: Error {
            case classifying([VisionRequestObject: Error], [[(Int, CGRect, CellType)]])
            case unknown
            case failedToFormatSlice
        }
    }
}

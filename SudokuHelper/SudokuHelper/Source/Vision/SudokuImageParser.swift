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

protocol SudokuImageParserDelegate: AnyObject {
    func sudokuImageParser(_ parser: SudokuImageParser, didChangeState newState: SudokuImageParser.State)
    func didDetectSudoku(in object: VisionRequestObject)
    func shouldParseSudokuCells(_ object: VisionRequestObject) -> Bool
    func failedToParseSudoku(_ error: SudokuParsingError?)
}

/// Errors from parsing
enum SudokuParsingError: Error {
    case visionRequestInitFailed(Error)
    case visionRequestError(Error)
    case invalidResponse
}

class SudokuImageParser {
    private static let parsingQueue = DispatchQueue(
        label: Bundle.main.bundleIdentifier ?? "" + ".SudokuImageParsingQueue",
        qos: .userInitiated
    )
    
    enum State {
        case idle
        case searching(image: CGImage)
        case parsingCells(visionObject: VisionRequestObject)
        case classifyingCells(image: CGImage, visionObjects: [VisionRequestObject])
        case parsed([[Int]])
    }
    
    private(set) var state: State = .idle {
        didSet {
            DispatchQueue.main.async { [weak self, state] in
                guard let self = self else { return }
                
                self.delegate?.sudokuImageParser(self, didChangeState: state)
            }
        }
    }
    private var sudokuVisionRequest: VisionRequest?
    private var sudokuCellVisionRequest: VisionRequest?
    private var cellClassifierTask: CellClassifierTask?
    
    weak var delegate: SudokuImageParserDelegate?
    
}

extension SudokuImageParser {
    func parseSudoku(
        from image: CGImage,
        responseQueue: DispatchQueue = .main
    ) {
        Self.parsingQueue.async { [weak self] in
            guard
                let self = self,
                case .idle = self.state,
                !(self.sudokuVisionRequest?.isRunning ?? false)
            else { return }
            
            self.state = .searching(image: image)
            
            do {
                self.sudokuVisionRequest = try VisionRequest.buildSudokuRequest(given: image)
            } catch {
                self.state = .idle
                self.delegate?.failedToParseSudoku(.visionRequestInitFailed(error))
                return
            }
            
            self.sudokuVisionRequest?.execute(responseQueue) { [weak self] result in
                responseQueue.async {
                    defer {
                        self?.sudokuVisionRequest = nil
                    }
                    
                    switch result {
                    case .success(let objects):
                        guard
                            objects.count > 0,
                            let mostConfidentResult = objects
                                .sorted(by: {$0.confidence > $1.confidence })
                                .first
                        else {
                            self?.state = .idle
                            return
                        }
                        
                        self?.delegate?.didDetectSudoku(in: mostConfidentResult)
                        
                        if self?.delegate?.shouldParseSudokuCells(mostConfidentResult) ?? false {
                            self?.parseSudokuCells(from: mostConfidentResult)
                        } else {
                            self?.state = .idle
                        }
                        
                    case .failure(let error):
                        self?.state = .idle
                        self?.delegate?.failedToParseSudoku(.visionRequestError(error))
                    }
                }
            }
        }
        
    }
    
    private func parseSudokuCells(from visionObject: VisionRequestObject, responseQueue: DispatchQueue = .main) {
        Self.parsingQueue.async { [weak self] in
            guard
                let self = self,
                self.sudokuCellVisionRequest?.isRunning != true
            else {
                return
            }
            
            self.state = .parsingCells(visionObject: visionObject)
            let image = visionObject.slice
            
            do {
                self.sudokuCellVisionRequest = try VisionRequest.buildSudokuCellRequest(given: image)
            } catch {
                self.state = .idle
                responseQueue.async { [weak self] in
                    self?.delegate?.failedToParseSudoku(.visionRequestInitFailed(error))
                }
                return
            }
            
            self.sudokuCellVisionRequest?.execute(responseQueue) { [weak self, image] result in
                guard let self = self else { return }
                
                defer {
                    self.sudokuCellVisionRequest = nil
                }
                
                switch result {
                case let .success(visionObjects):
                    print("detected \(visionObjects.count) vision objects")
                    guard visionObjects.count == 81 else {
                        responseQueue.async {
                            self.delegate?.failedToParseSudoku(.visionRequestError(NSError()))
                        }
                        return
                    }
                    self.state = .classifyingCells(image: image, visionObjects: visionObjects)
                    let sortedObject = SudokuCellOrganizer.organize(sudokuCellObjects: visionObjects, foundIn: image)
                    self.cellClassifierTask = CellClassifierTask(cellVisionObjects: sortedObject)
                    
                    self.cellClassifierTask?.classifyCells(responseQueue: responseQueue) { result in
                        switch result {
                        case let .success(puzzleDigits):
                            print("Classified images:")
                            for row in puzzleDigits {
                                print(row.map({ $0 == 0 ? "_" : "\($0)" }).joined(separator: "."))
                            }
                        case let .failure(error):
                            print(error.localizedDescription)
                            self.state = .idle
                        }
                    }
                    
                    // TODO: State to parsed or failure
                case let .failure(error):
                    // TODO: State to idle
                    print(error.localizedDescription)
                    self.state = .idle
                }
            }
        }
    }
}

// MARK: - CellClassifierTask

private extension SudokuImageParser {
    class CellClassifierTask {
        private let group = DispatchGroup()
        private let cellVisionObjects: [[VisionRequestObject]]
        private var result: [[Int]]
        private var errors = [VisionRequestObject: Error]()

        init(cellVisionObjects: [[VisionRequestObject]]) {
            self.cellVisionObjects = cellVisionObjects
            result = (0..<9).reduce(into: []) { result, _ in
                result.append(Array<Int>(repeating: -1, count: 9))
            }
        }
        
        func classifyCells(
            responseQueue: DispatchQueue,
            completion: @escaping (Result<[[Int]], Error>) -> Void
        ) {
            cellVisionObjects.enumerated().forEach { y, objectRow in
                objectRow.enumerated().forEach { x, object in
                    
                    if object.label == "empty" {
                        self.result[y][x] = 0
                        return
                    }
                    
                    let sliceImage = UIImage(cgImage: object.slice)

                    group.enter()

                    self.runDigitClassifier(on: sliceImage) { [weak self, object, group] result in
                        switch result {
                        case .success(let digit):
                            self?.result[y][x] = digit
                        case .failure(let error):
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
            case classifying([VisionRequestObject: Error], [[Int]])
            case unknown
            case failedToFormatSlice
        }
    }
}

//
//  SudokuImageParser.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 2/19/22.
//

import Foundation
import Combine
import CoreGraphics

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

    weak var delegate: SudokuImageParserDelegate?
    
}

extension SudokuImageParser {
    func parseSudoku(
        from image: CGImage,
        responseQueue: DispatchQueue = .main
    ) {
        guard !(sudokuVisionRequest?.isRunning ?? false) else { return }
        
        state = .searching(image: image)

        do {
            sudokuVisionRequest = try VisionRequest.buildSudokuRequest(given: image)
        } catch {
            state = .idle
            delegate?.failedToParseSudoku(.visionRequestInitFailed(error))
            return
        }

        sudokuVisionRequest?.execute(responseQueue) { [weak self] result in
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
    
    private func parseSudokuCells(from visionObject: VisionRequestObject, responseQueue: DispatchQueue = .main) {
        if sudokuCellVisionRequest?.isRunning == true { return }
        
        self.state = .parsingCells(visionObject: visionObject)
        let image = visionObject.slice
        
        do {
            sudokuCellVisionRequest = try VisionRequest.buildSudokuCellRequest(given: image)
        } catch {
            state = .idle
            responseQueue.async { [weak self] in
                self?.delegate?.failedToParseSudoku(.visionRequestInitFailed(error))
            }
            return
        }
        
        sudokuCellVisionRequest?.execute(responseQueue) { [weak self, image] result in
            guard let self = self else { return }
            
            defer {
                self.sudokuCellVisionRequest = nil
            }

            switch result {
            case let .success(visionObjects):
                print("detected \(visionObjects.count) vision objects")
                self.state = .classifyingCells(image: image, visionObjects: visionObjects)
                // TODO: Sort into matrix
                // TODO: parse digits in "filled" cells
                // TODO: State to parsed or failure
            case let .failure(error):
                // TODO: State to idle
                print(error.localizedDescription)
            }
        }
    }
}

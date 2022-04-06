//
//  SudokuDetector.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 4/5/22.
//

import CoreGraphics
import Foundation
import Vision

protocol SudokuDetectorTaskDelegate: AnyObject {
    func sudokuDetectorTask(_ task: SudokuDetectorTask, didDetectSudokuIn image: CGImage, at location: CGRect, withConfidence confidence: CGFloat)
    func sudokuDetectorTask(_ task: SudokuDetectorTask, failedToDetectSudokuWithError error: Error)
}

class SudokuDetectorTask {
    private static let detectingQueue = DispatchQueue(
        label: Bundle.main.bundleIdentifier ?? "" + ".SudokuDetectorTask",
        qos: .userInitiated
    )
    
    enum State {
        case idle
        case detecting
        case detectedSudoku(location: CGRect, confidence: CGFloat)
    }

    let id = UUID()
    weak var delegate: SudokuDetectorTaskDelegate?
    private(set) var state: State = .idle
    private var sudokuVisionRequest: VisionRequest?
    let image: CGImage
    private let responseQueue: DispatchQueue
    
    init(
        delegate: SudokuDetectorTaskDelegate? = nil,
        image: CGImage,
        responseQueue: DispatchQueue = .main
    ) {
        self.delegate = delegate
        self.image = image
        self.responseQueue = responseQueue
    }
}

// MARK: - SudokuDetectorTask+Hashable

extension SudokuDetectorTask: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SudokuDetectorTask, rhs: SudokuDetectorTask) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Execute

extension SudokuDetectorTask {
    func execute() {
        Self.detectingQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard
                case .idle = self.state
            else {
                self.delegate?.sudokuDetectorTask(
                    self,
                    failedToDetectSudokuWithError: DetectError.alreadyRunning
                )
                return
            }
            
            self.state = .detecting
            
            do {
                let modelConfig = MLModelConfiguration()
                #if targetEnvironment(simulator)
                modelConfig.computeUnits = .cpuOnly
                #endif
                let sudokuModel = try SudokuDetector(configuration: modelConfig)
                let model = try VNCoreMLModel(for: sudokuModel.model)
                
                self.sudokuVisionRequest = VisionRequest(
                    modelName: "SudokuDetector",
                    model: model,
                    image: self.image,
                    // 5% expansion seems to be useful
                    sliceInset: .init(0.025),
                    requiredConfidence: 0.6
                )
            } catch {
                self.state = .idle
                self.delegate?.sudokuDetectorTask(
                    self,
                    failedToDetectSudokuWithError: DetectError.failedToInitialize(error)
                )
                return
            }
            
            self.sudokuVisionRequest?.execute(self.responseQueue) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let objects):
                    guard
                        objects.count > 0,
                        let mostConfidentResult = objects
                            .sorted(by: {$0.confidence > $1.confidence })
                            .first
                    else {
                        self.state = .idle
                        self.delegate?.sudokuDetectorTask(
                            self,
                            failedToDetectSudokuWithError: DetectError.didntFindSudoku(nil)
                        )
                        return
                    }
                    
                    self.delegate?.sudokuDetectorTask(
                        self,
                        didDetectSudokuIn: self.image,
                        at: mostConfidentResult.location,
                        withConfidence: mostConfidentResult.confidence
                    )
                    
                case .failure(let error):
                    self.delegate?.sudokuDetectorTask(
                        self,
                        failedToDetectSudokuWithError: DetectError.didntFindSudoku(error)
                    )
                }
            }
        }
    }
}

// MARK: - DetectError

extension SudokuDetectorTask {
    enum DetectError: Error {
        case alreadyRunning
        case failedToInitialize(Error)
        case didntFindSudoku(Error?)
    }
}

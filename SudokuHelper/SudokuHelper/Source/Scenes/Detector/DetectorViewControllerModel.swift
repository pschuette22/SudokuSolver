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

    private let requiredConfidence: Float
    private let sudokuModelURL: URL
    
    init(
        initialState state: DetectorViewControllerState = .init(),
        requiredConfidence: Float = 0.95,
        sudokuModelURL: URL = Bundle.main.url(forResource: "Sudoku", withExtension: "mlmodelc")!
    ) {
        self.requiredConfidence = requiredConfidence
        self.sudokuModelURL = sudokuModelURL
        
        super.init(initialState: state)
    }
}

extension DetectorViewControllerModel {
    
    func didStartCaptureSession() {
        
    }
    
    func didEndCaptureSession() {
        
    }
    
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
        let modelConfig = MLModelConfiguration()
        modelConfig.computeUnits = .all
        
        guard
            let sudokuModel = try? Sudoku(configuration: modelConfig),
            let visionModel = try? VNCoreMLModel(for: sudokuModel.model)
        else {
            didNotDetectSudoku()
            return
        }

        let objectDetectionRequest = VNCoreMLRequest(model: visionModel) {
            [weak self, image, bufferSize, dispatchQueue, requiredConfidence] (request, error) in
            dispatchQueue.async {
                // perform all the UI updates on the main queue
                guard
                    let results = request.results,
                    let mostConfident = results.first as? VNRecognizedObjectObservation
                else {
                    self?.didNotDetectSudoku()
                    return
                }
                
                var objectBounds = VNImageRectForNormalizedRect(mostConfident.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
                // expand by 5% for blank space padding
                let horizontalExpand = objectBounds.width * 0.05
                let verticalExpand = objectBounds.height * 0.05
                objectBounds.origin.x -= horizontalExpand / 2
                objectBounds.origin.y -= verticalExpand / 2
                objectBounds.size.height += verticalExpand
                objectBounds.size.height += horizontalExpand
                // Flipped for UIKit orientation origin
//                var boundingBox = mostConfident.boundingBox
//                // Scale for center crop. Assumes center square of image was used to identify sudoku
//                let longSide = max(bufferSize.width, bufferSize.height)
//                let scaleX = (longSide - bufferSize.width) / (bufferSize.width * 2)
//                let scaleY = (longSide - bufferSize.height) / (bufferSize.height * 2)
//                boundingBox.origin = .init(
//                    x: boundingBox.origin.x + scaleX,
//                    y: boundingBox.origin.y + scaleY
//                )
//                boundingBox.origin.y = 1 - (boundingBox.origin.y + boundingBox.height)
                objectBounds.origin.y = bufferSize.height - (objectBounds.height + objectBounds.origin.y)
                self?.update {
                    $0.toDetectedSudoku(
                        in: image,
                        withSize: bufferSize,
                        frameInImage: objectBounds,
                        confidence: mostConfident.confidence
                    )
                }
                
                if mostConfident.confidence > requiredConfidence {
//                    self?.parseSudoku(in: image, ofSize: bufferSize, withFrame: objectBounds)
                } else {
                    // TODO: something else?
                }
            }
        }
        
        objectDetectionRequest.imageCropAndScaleOption = .scaleFill
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        DispatchQueue.global(qos: .userInitiated).async { [handler, objectDetectionRequest] in
            do {
                try handler.perform([objectDetectionRequest])
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    func didFailToSetupCaptureSession(_ error: Error? = nil) {
        // TODO: State to error state
        Logger.log(.error, message: "Failed to setup capture session", params: ["error": error?.localizedDescription ?? "<nil>"])
    }
    
    func didFailToStartCaptureSession(_ error: Error) {
        Logger.log(.error, message: "Failed to start capture session", params: ["error": error])
    }
}

// MARK: - Image Parsing

extension DetectorViewControllerModel {
    func parseSudoku(in image: CGImage, ofSize size: CGSize, withFrame frame: CGRect) {
        guard case .detectedSudoku = state.context else { return }
        
//        // Do I need to expand the clipping at all to ensure that the whole puzzle w/ boarders is captured ?
//        let clippedImageFrame = CGRect(
//            x: frame.origin.x * size.width,
//            y: frame.origin.y * size.height,
//            width: frame.width * size.width,
//            height: frame.height * size.height
//        )
//
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


extension CGRect: CustomStringConvertible {
    public var description: String {
        "x:\(origin.x),y:\(origin.y),h:\(height),w:\(width)"
    }
}

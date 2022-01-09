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

final class DetectorViewControllerModel: ViewModel<DetectorViewControllerState> {

    private let requiredConfidence: Float
    private let sudokuModelURL: URL
    
    init(
        initialState state: DetectorViewControllerState = .init(),
        requiredConfidence: Float = 0.85,
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
                
                // Flipped for UIKit orientation origin
                var boundingBox = mostConfident.boundingBox
                print("original bounds: \(mostConfident.boundingBox)")
                // Scale for center crop. Assumes center square of image was used to identify sudoku
                let smallSide = min(bufferSize.width, bufferSize.height)
                let scaleX = (bufferSize.width - smallSide) / (bufferSize.width * 2)
                let scaleY = (bufferSize.height - smallSide) / (bufferSize.height * 2)
                boundingBox.origin = .init(
                    x: boundingBox.origin.x + scaleX,
                    y: boundingBox.origin.y + scaleY
                )
                print("Scaled bounds \(boundingBox)")
                boundingBox.origin.y = 1 - (boundingBox.origin.y + boundingBox.height)
                print("Flipped bounds: \(boundingBox)")

//                CGRect(
//                    x: mostConfident.boundingBox.origin.x,
//                    y: mostConfident.boundingBox.origin.y, // + mostConfident.boundingBox.height),
//                    width: mostConfident.boundingBox.width,
//                    height: mostConfident.boundingBox.height
//                )
                
                
                
//                let objectBounds = VNImageRectForNormalizedRect(
//                    boundingBox,
//                    Int(bufferSize.width),
//                    Int(bufferSize.height)
//                )

//                let width = container.width
//                let height = container.height
//                let boundingBox = CGRect(
//                    x: width * mostConfident.boundingBox.origin.x,
//                    y: height * mostConfident.boundingBox.origin.y,
//                    width: width * mostConfident.boundingBox.width,
//                    height: height * mostConfident.boundingBox.height)
//
                self?.update {
                    $0.toDetectedSudoku(
                        in: image,
                        withSize: bufferSize,
                        frameInImage: boundingBox,
                        confidence: mostConfident.confidence
                    )
                }
                
                if mostConfident.confidence > requiredConfidence {
                    print("Confidently found bounds: \(boundingBox)")
                } else {
                    // TODO: something else?
                }
            }
        }
        
        objectDetectionRequest.imageCropAndScaleOption = .centerCrop
        
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


extension CGRect: CustomStringConvertible {
    public var description: String {
        "x:\(origin.x),y:\(origin.y),h:\(height),w:\(width)"
    }
}

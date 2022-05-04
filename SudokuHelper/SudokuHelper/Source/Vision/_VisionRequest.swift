//
//  VisionRequest.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 2/19/22.
//

import CoreGraphics
import UIKit
import Vision

struct VisionRequestObject: Hashable {
    let id: UUID = UUID()
    let label: String?
    let location: CGRect
    let originalImageSize: CGSize
    let confidence: CGFloat
    let slice: CGImage
}

class VisionRequest {
    typealias Completion = (Result<[VisionRequestObject], Error>) -> Void
    private static let defaultWorkerQueue = DispatchQueue(
        label: Bundle.main.bundleIdentifier ?? "" + ".VisionRequest",
        qos: .default
    )
    let modelName: String?
    let model: VNCoreMLModel
    let image: CGImage
    let workerQueue: DispatchQueue
    let sliceInset: UIEdgeInsets
    let fittingStrategy: VNImageCropAndScaleOption
    let requiredConfidence: CGFloat
    private(set) var isRunning: Bool = false

    required init(
        modelName: String? = nil,
        model: VNCoreMLModel,
        image: CGImage,
        workerQueue: DispatchQueue = defaultWorkerQueue,
        sliceInset: UIEdgeInsets = .zero,
        fittingStrategy: VNImageCropAndScaleOption = .scaleFit,
        requiredConfidence: CGFloat = 0.75
    ) {
        self.modelName = modelName
        self.model = model
        self.image = image
        self.workerQueue = workerQueue
        self.sliceInset = sliceInset
        self.fittingStrategy = fittingStrategy
        self.requiredConfidence = requiredConfidence
    }
}

//MARK: - Execute
extension VisionRequest {
    /// Execute the vision request
    /// - Parameters:
    ///   - responseQueue: ```DispatchQueue``` the completion should be executed on
    ///   - completion: ```Completion``` block which dispatches the result
    func execute(_ responseQueue: DispatchQueue, _ completion: Completion?) {
        guard !isRunning else {
            Logger.log(.error, message: "Already running!")
            return
        }
        
        let objectDetectionRequest = VNCoreMLRequest(model: model) {
            [weak self, image, requiredConfidence, completion] (request, error) in
            
            var result: Result<[VisionRequestObject], Error>!
            
            defer {
                responseQueue.async {
                    completion?(result)
                }
            }
            
            guard
                let self = self,
                let results = request.results
            else {
                result = .success([])
                return
            }
            let imageSize = CGSize(width: image.width, height: image.height)
            let visionObjects: [VisionRequestObject] = results.compactMap {
                guard let object = $0 as? VNRecognizedObjectObservation else { return nil }

                let label = object.labels.sorted(by: { $0.confidence > $1.confidence }).first?.identifier
                let confidence = CGFloat(object.confidence)

                guard
                    confidence >= requiredConfidence
                else {
                    Logger.log(
                        .debug,
                        message: "Not confident enough",
                        params: [
                            "model": self.modelName ?? "<not-specified>",
                            "label": label ?? "<not-found>",
                            "location": object.boundingBox,
                            "confidence": object.confidence
                        ]
                    )
                    return nil
                }
                
                let normalizedFrame = self.normalize(object.boundingBox)

                guard
                    let imageSlice = image.cropping(to: normalizedFrame)
                else {
                    return nil
                }

                return .init(
                    label: label,
                    location: normalizedFrame,
                    originalImageSize: imageSize,
                    confidence: confidence,
                    slice: imageSlice)
            }
            
            result = .success(visionObjects)
        }
        
        objectDetectionRequest.imageCropAndScaleOption = fittingStrategy
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        workerQueue.async { [weak responseQueue, handler, objectDetectionRequest] in
            do {
                try handler.perform([objectDetectionRequest])
            } catch {
                responseQueue?.async {
                    completion?(.failure(error))
                }
            }
        }
    }
}


// MARK: - Normalizing

extension VisionRequest {
    func normalize(_ frame: CGRect) -> CGRect {
        var objectBounds = VNImageRectForNormalizedRect(frame, image.width, image.height)
        
        // Flip for UIKit/CoreGraphics frame coordinate system
        objectBounds.origin.y = CGFloat(image.height) - (objectBounds.height + objectBounds.origin.y)
        
        switch fittingStrategy {
        case .scaleFit:
            objectBounds = normalizeScaleToFit(objectBounds)
        case .centerCrop:
            objectBounds = normalizeCenterCrop(objectBounds)
        case .scaleFill:
            objectBounds = normalizeScaleToFill(objectBounds)
        @unknown default:
            
            break
        }
        
        // Convert from percent based to size based
        objectBounds.origin.x -= frame.width * sliceInset.left
        objectBounds.origin.y -= frame.height * sliceInset.top
        objectBounds.size.height += frame.height * (sliceInset.top + sliceInset.bottom)
        objectBounds.size.width += frame.width * (sliceInset.left + sliceInset.right)
        
        return objectBounds
    }
    
    private func normalizeScaleToFit(_ frame: CGRect) -> CGRect {
        
        return frame
    }
    
    private func normalizeCenterCrop(_ frame: CGRect) -> CGRect {
        return frame
    }
    
    private func normalizeScaleToFill(_ frame: CGRect) -> CGRect {
        return frame
    }
}

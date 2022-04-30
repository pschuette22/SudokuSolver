//
//  PuzzleDigitClassifier.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 3/25/22.
//

import Foundation
import UIKit
import CoreGraphics
import Vision

class PuzzleDigitClassifier {
    func classifyDigit(in image: UIImage, _ completion: @escaping (Result<Int, Error>) -> Void) {
        guard
            let transformed = PureBlackWhiteFilter()
                .apply(to: image)?
                .inverted()
        else {
            completion(.failure(ClassifyingError.failedToInitialize))
            return
        }
        
        // TODO: handle over and under filtering

        let isolatedImage = isolateDigit(in: transformed)
        
        UIGraphicsBeginImageContext(.init(width: 28, height: 28))
        UIImage(cgImage: isolatedImage).draw(in: CGRect(origin: .zero, size: .init(width: 28, height: 28)))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let resizedImage = resizedImage?.cgImage else {
            completion(.failure(ClassifyingError.failedToInitialize))
            return
        }
        
        let config = MLModelConfiguration()
        #if targetEnvironment(simulator)
        config.computeUnits = .cpuOnly
        #endif
        
        do {
            let digitClassifier = try MNISTClassifier(configuration: config)
            let classifierModel = try VNCoreMLModel(for: digitClassifier.model)
            let classificationRequest = VNCoreMLRequest(model: classifierModel) { [image, resizedImage] request, error in
                _ = image
                _ = resizedImage
                if
                    let result = request.results?.first as? VNClassificationObservation,
                    let identifiedInt = Int(result.identifier)
                {
                    print("identified: \(identifiedInt), confidence: \(result.confidence)")
                    var others = request.results ?? []
                    others.remove(result)
                    print("others: " + others
                        .map({ "\(($0 as? VNClassificationObservation)?.identifier ?? "<err>"): \($0.confidence)" })
                        .joined(separator: ", ")
                    )

                    completion(.success(identifiedInt))
                } else {
                    completion(.failure(error ?? ClassifyingError.unknown))
                }
            }

            classificationRequest.imageCropAndScaleOption = .centerCrop
            #if targetEnvironment(simulator)
            classificationRequest.usesCPUOnly = true
            #endif
            let handler = VNImageRequestHandler(cgImage: resizedImage, orientation: .up)
            try handler.perform([classificationRequest])
            
        } catch {
            completion(.failure(error))
        }
    }

    private func isolateDigit(in image: CGImage) -> CGImage {
        let frame = frameOfDigit(in: image)
        // Redraw image and convert all pixels outside of digit area to black

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let width = Int(image.width)
        let height = Int(image.height)
        let bytesPerRow = width * 4
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        
        guard let imageContext = CGContext(
             data: imageData,
             width: width,
             height: height,
             bitsPerComponent: 8,
             bytesPerRow: bytesPerRow,
             space: colorSpace,
             bitmapInfo: bitmapInfo
        ) else { return image }
        
        imageContext.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        let pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        
        for y in 0..<image.height {
            for x in 0..<image.width {
                if
                    (frame.topLeft.x...frame.bottomRight.x).contains(x) &&
                    (frame.topLeft.y...frame.bottomRight.y).contains(y)
                {
                    continue
                }
                let index = y * width + x
                pixels[index] = .black
            }
        }
        
        let isolatedImage = imageContext.makeImage() ?? image
        var croppingFrame = CGRect(
            x: frame.topLeft.x,
            y: frame.topLeft.y,
            width: frame.bottomRight.x - frame.topLeft.x,
            height: frame.bottomRight.y - frame.topLeft.y
        )
        
        // Resize to a square to preserve dimensions
        if croppingFrame.width > croppingFrame.height {
            croppingFrame.origin.y -= (croppingFrame.width - croppingFrame.height) / 2
            croppingFrame.size.height = croppingFrame.width
        } else if croppingFrame.height > croppingFrame.width {
            croppingFrame.origin.x -= (croppingFrame.height - croppingFrame.width) / 2
            croppingFrame.size.width = croppingFrame.height
        }
        
        let fortyPercent = croppingFrame.width * 0.4
        croppingFrame.origin.x = croppingFrame.origin.x - fortyPercent
        croppingFrame.origin.y = croppingFrame.origin.y - fortyPercent
        croppingFrame.size.width = croppingFrame.size.width + (2 * fortyPercent)
        croppingFrame.size.height = croppingFrame.size.height + (2 * fortyPercent)
        
        return isolatedImage.cropping(to: croppingFrame) ?? image
    }
    
    private func frameOfDigit(
        in image: CGImage
    ) -> (topLeft: (x: Int, y: Int), bottomRight: (x: Int, y: Int)) {
        let matrix = buildBlackWhiteMatrix(of: image)

        assert(matrix.isEmpty == false)
        
        var topLeft = (x: image.width / 2, y: image.height / 2)
        var bottomRight = (x: topLeft.x + 1, y: topLeft.y + 1)
        var hasFoundImage = false
        // start with bounding area, look for white pixel
        outerLoop: for _ in 0..<min(topLeft.y, topLeft.x) {
            for y in topLeft.y...bottomRight.y {
                if matrix[safe: y]?[safe: topLeft.x] == false {
                    topLeft = (x: topLeft.x, y: y)
                    bottomRight = (x: topLeft.x, y: y)
                    hasFoundImage = true
                    break outerLoop
                } else if matrix[safe: y]?[safe: bottomRight.x] == false {
                    topLeft = (x: bottomRight.x, y: y)
                    bottomRight = (x: bottomRight.x, y: y)
                    hasFoundImage = true
                    break outerLoop
                }
            }

            for x in topLeft.x...bottomRight.x {
                if matrix[safe: topLeft.y]?[safe: x] == false {
                    topLeft = (x: x, y: topLeft.y)
                    bottomRight = (x: x, y: topLeft.y)
                    hasFoundImage = true
                    break outerLoop
                } else if matrix[safe: bottomRight.y]?[safe: x] == false {
                    topLeft = (x: x, y: bottomRight.y)
                    bottomRight = (x: x, y: bottomRight.y)
                    hasFoundImage = true
                    break outerLoop
                }
            }
            
            // expand by one in each direction until found.
            topLeft = (x: topLeft.x-1, y: topLeft.y-1)
            bottomRight = (x: bottomRight.x+1, y: bottomRight.y+1)
        }
        
//        assert(hasFoundImage)
        
        // work out by 1 in each direction until all white pixels have been encapsulated / surrounded with a single layer of dark pixels
        outerloop: while true {
            // Expand on y
            for y in topLeft.y...bottomRight.y {
                if matrix[safe: y]?[safe: topLeft.x] == false {
                    topLeft.x -= 1
                    continue outerloop
                } else if matrix[safe: y]?[safe: bottomRight.x] == false {
                    bottomRight.x += 1
                    continue outerloop
                }
            }

            // Expand on x
            for x in topLeft.x...bottomRight.x {
                if matrix[safe: topLeft.y]?[safe: x] == false {
                    topLeft.y -= 1
                    continue outerloop
                } else if matrix[safe: bottomRight.y]?[safe: x] == false {
                    bottomRight.y += 1
                    continue outerloop
                }
            }

            break
        }
        // This is the bounding area
        #if DEBUG
        print("Isolated digit image:\n")
        for y in max(topLeft.y, 0)...min(bottomRight.y, matrix.count-1) {
            guard
                matrix.indices.contains(y),
                let indicies = matrix.first
            else {
                continue
            }
            let lhs = max(indicies.startIndex, topLeft.x)
            let rhs = min(indicies.endIndex-1, bottomRight.x)
            print(matrix[y][lhs...rhs]
                .map({ $0 ? "X" : " "})
                .joined()
            )
        }
        #endif

        return (topLeft: topLeft, bottomRight: bottomRight)
    }
}

private extension PuzzleDigitClassifier {
    struct Pixel: Equatable {
        var r: UInt8
        var g: UInt8
        var b: UInt8
        var a: UInt8

        /// Calculate the average of r,g,b values
        var brightness: UInt8 {
            let sorted = [r, g, b].sorted()
            let lhsDelta = sorted[2] - sorted[1]
            let rhsDelta = sorted[1] - sorted[0]
            if lhsDelta > rhsDelta {
                // lowest number + delta to highest
                return sorted[0] + (lhsDelta - rhsDelta)
            } else {
                // highest number - delta to lowest
                return sorted[2] - (rhsDelta - lhsDelta)
            }
        }
        
        var description: String {
            "\(r).\(g).\(b).\(a)"
        }
        
        static var black: Pixel {
            .init(r: .min, g: .min, b: .min, a: .max)
        }
        
        static var white: Pixel {
            .init(r: .max, g: .max, b: .max, a: .max)
        }
    }

    /// Converts the image to an array of booleans indicating if current boolean is dark or light
    /// Light booleans contain a brightness of less than 127 / 225
    /// - Returns: ```[[Bool]]```
    func buildBlackWhiteMatrix(of image: CGImage) -> [[Bool]] {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let width = Int(image.width)
        let height = Int(image.height)
        let bytesPerRow = width * 4
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        
        guard let imageContext = CGContext(
             data: imageData,
             width: width,
             height: height,
             bitsPerComponent: 8,
             bytesPerRow: bytesPerRow,
             space: colorSpace,
             bitmapInfo: bitmapInfo
        ) else { return [] }
        
        imageContext.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        let pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        // Initialize a width x height array of arrays of booleans
        var result = [[Bool]]()
        
        for y in 0..<image.height {
            var row = [Bool]()
            for x in 0..<image.width {
                let index = y * width + x
                let pixel = pixels[index]
                row.append(pixel.brightness < 127)
            }
            result.append(row)
        }
        
        return result
    }
}

// MARK: - ClassifyingError

extension PuzzleDigitClassifier {
    enum ClassifyingError: Error {
        case failedToInitialize
        case failedToConvertToMNISTFormat
        case unknown
    }
}

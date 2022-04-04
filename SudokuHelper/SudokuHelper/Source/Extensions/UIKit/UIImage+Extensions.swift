//
//  UIImage+Extensions.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 2/27/22.
//

import CoreGraphics
import CoreImage
import UIKit

extension UIImage {
    func inverted() -> CGImage? {
        var ciImage = self.ciImage
        if
            ciImage.isNil,
            let cgImage = self.cgImage
        {
            ciImage = CIImage(cgImage: cgImage)
        }
        
        guard let ciImage = ciImage else { return nil }
        
        let context = CIContext(options: nil)
        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            if let output = filter.outputImage {
                return context.createCGImage(output, from: output.extent)
            }
        }

        return nil
    }
    
    func increaseContrast(_ value: Double) -> CGImage? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let parameters = [
            "inputContrast": NSNumber(value: value)
        ]
        let outputImage = inputImage.applyingFilter("CIColorControls", parameters: parameters)

        let context = CIContext(options: nil)
        return context.createCGImage(outputImage, from: outputImage.extent)
    }
}


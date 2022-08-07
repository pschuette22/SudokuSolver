//
//  PureBlackWhiteFilter.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 3/26/22.
//

import Foundation
import CoreImage
import UIKit

class PureBlackWhiteFilter: CIFilter {
    private lazy var kernel: CIKernel = {
      guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"), let data = try? Data(contentsOf: url) else {
        fatalError("Unable to load metallib")
      }
      let name = "thresholdFilterKernel"
      guard let kernel = try? CIKernel(functionName: name, fromMetalLibraryData: data) else {
        fatalError("Unable to create the CIColorKernel for filter \(name)")
      }
      return kernel
    }()
    
    func apply(to image: UIImage, threshold: Float = 0.35) -> UIImage? {
        guard
            let cgImage = image.cgImage
        else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let coreImage = kernel.apply(
            extent: ciImage.extent,
            roiCallback: {(index, rect) -> CGRect in return rect},
            arguments: [ciImage, threshold]
        ) else { return nil }
                
        return UIImage(ciImage: coreImage)
    }
}

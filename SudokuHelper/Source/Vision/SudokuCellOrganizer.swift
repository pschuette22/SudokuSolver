//
//  SudokuCellOrganizer.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 2/20/22.
//

import Foundation
import CoreGraphics

enum SudokuCellOrganizer {
    static func organize(sudokuCellObjects: [VisionRequestObject], foundIn image: CGImage) -> [[VisionRequestObject]] {
        precondition(sudokuCellObjects.count == 81)
        
        // TODO: determine if a "smarter" version is needed
        var result = [[VisionRequestObject]]()
        var objects = sudokuCellObjects.sorted { $0.location.origin.y < $1.location.origin.y }

        for _ in 0..<9 {
            var subset = Array(objects[0..<9])
            objects.removeFirst(9)
            // sort the subset left to right
            subset.sort(by: { $0.location.origin.x < $1.location.origin.x })
            result.append(subset)
        }

        return result
    }
}

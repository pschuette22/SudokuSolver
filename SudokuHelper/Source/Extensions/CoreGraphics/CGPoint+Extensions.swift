//
//  CGPoint+Extensions.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 2/20/22.
//

import CoreGraphics


extension CGPoint {
    /// Calculates the distance between two points, assuming the same coordinate plane
    /// - Parameter other: ```CGPoint``` we would like to know the distance to
    /// - Returns: Calculated distance between the two points using Pythagorean theorem
    func distance(to other: CGPoint) -> CGFloat {
        let xDelta = abs(x - other.x)
        let yDelta = abs(y - other.y)

        return sqrt(pow(xDelta, 2) + pow(yDelta, 2))
    }
}

//
//  CGRect+Extensions.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/6/22.
//

import CoreGraphics

extension CGRect {
    var area: CGFloat {
        (width - origin.x) * (height - origin.y)
    }
}

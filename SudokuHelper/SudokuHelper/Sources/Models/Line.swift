//
//  Line.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation


final class Line: NSObject, Group {
    enum Axis: CaseIterable {
        case horizontal
        case vertical
        
        var other: Axis {
            switch self {
            case .horizontal:
                return .vertical
            case .vertical:
                return .horizontal
            }
        }
    }

    let id = UUID()
    var cells: [Cell]
    let axis: Axis
    
    init(_ axis: Axis, cells: [Cell]) {
        self.cells = cells
        self.axis = axis
        super.init()
        
        cells.forEach {
            switch axis {
            case .horizontal:
                $0.horizontalLine = self

            case .vertical:
                $0.verticalLine = self
            }
        }        
    }
}


// MARK: - Line+Equatable
extension Line {
    static func == (lhs: Line, rhs: Line) -> Bool {
        lhs.id == rhs.id
    }
}

//
//  Line.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation


final class Line: Group {
    enum Axis {
        case horizontal
        case vertical
    }

    let id = UUID()
    var cells: [Cell]
    let axis: Axis
    
    init(_ axis: Axis, cells: [Cell]) {
        self.cells = cells
        self.axis = axis
        
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
extension Line: Equatable {
    static func == (lhs: Line, rhs: Line) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Line+Hashable
extension Line: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


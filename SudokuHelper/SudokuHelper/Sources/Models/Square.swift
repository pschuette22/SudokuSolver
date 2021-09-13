//
//  Square.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation

final class Square: NSObject, Group {
    let id = UUID()
    var arrangedCells: [[Cell]]
    var cells: [Cell] {
        arrangedCells.flattened
    }
    
    init(arrangedCells: [[Cell]]) {
        self.arrangedCells = arrangedCells
        super.init()
        arrangedCells.flattened.forEach { $0.square = self }
    }
}

// MARK: - Square+Equatable
extension Square {
    static func == (lhs: Square, rhs: Square) -> Bool {
        lhs.id == rhs.id
    }
}

//
//  Square.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation

final class Square: Group {
    let id = UUID()
    var arrangedCells: [[Cell]]
    var cells: [Cell] {
        arrangedCells.flatMap { $0 }
    }
    
    init(arrangedCells: [[Cell]]) {
        self.arrangedCells = arrangedCells
        cells.forEach { $0.square = self }
    }
}

// MARK: - Square+Equatable
extension Square: Equatable {
    static func == (lhs: Square, rhs: Square) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Square+Hashable
extension Square: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

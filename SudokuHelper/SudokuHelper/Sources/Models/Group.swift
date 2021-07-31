//
//  Group.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation


protocol Group: AnyObject, Identifiable, Hashable {
    var cells: [Cell] { get }
}


extension Group {
    var isSolved: Bool {
        cells.first(where: { $0.value == nil }) == nil
    }
    
    var remainingValues: Set<Int> {
        var values = Set<Int>(1...9)
        cells.forEach {
            guard let value = $0.value else { return }

            values.remove(value)
        }
        return values
    }
}

extension Group {
    @discardableResult
    func remove(possibility: Int) -> [Cell] {
        cells.filter{ $0.possibilities.remove(possibility) != nil }
    }
}

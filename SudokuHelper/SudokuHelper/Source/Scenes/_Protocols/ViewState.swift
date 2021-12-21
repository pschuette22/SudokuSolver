//
//  ViewState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/1/21.
//

import Foundation


protocol ViewState: Hashable { }

extension ViewState {
    mutating
    func update(_ changeHandler: @escaping (inout Self) -> Self) {
        var copy = self
        self = changeHandler(&copy)
    }
}

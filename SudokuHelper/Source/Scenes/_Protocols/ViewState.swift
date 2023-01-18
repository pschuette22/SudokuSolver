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
    func update(_ changeHandler: (inout Self) -> Void) {
        var updated = self
        changeHandler(&updated)
        self = updated
    }
}

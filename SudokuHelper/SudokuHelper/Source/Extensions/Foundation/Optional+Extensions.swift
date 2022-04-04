//
//  Optional+Extensions.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 3/26/22.
//

import Foundation

extension Optional {
    var isNil: Bool {
        switch self {
        case .some:
            return false
        case .none:
            return true
        }
    }
    
    var isNotNil: Bool { isNil == false }
}

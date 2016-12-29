//
//  Utils.swift
//  SudokuSolver
//
//  Created by Schuette, Peter on 12/24/16.
//  Copyright © 2016 Schuette, Peter. All rights reserved.
//

import Foundation


class Utils {
    
    
    static func primeKey(for value: UInt) -> UInt {
        switch value {
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return 5
        case 4:
            return 7
        case 5:
            return 11
        case 6:
            return 13
        case 7:
            return 17
        case 8:
            return 19
        case 9:
            return 23
        default:
            return 1
        }
    
    
    }
    
}

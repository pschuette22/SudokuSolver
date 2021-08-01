//
//  Array+Extensions.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/31/21.
//

import Foundation


extension Array where Element: Hashable {
    
    var set: Set<Element> {
        Set(self)
    }
    
}

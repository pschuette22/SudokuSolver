//
//  String+Extensions.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/31/21.
//

import Foundation


extension String {
    @discardableResult
    mutating
    func trimCharacters(in characterSet: CharacterSet) -> String {
        self = trimmingCharacters(in: characterSet)
        return self
    }
    
    @discardableResult
    mutating
    func removeCharacters(in characterSet: CharacterSet) -> String {
        self = self.components(separatedBy: characterSet).joined()
        return self
    }
}

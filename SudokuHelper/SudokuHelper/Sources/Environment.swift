//
//  Environment.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation


final class Environment {
    var date: () -> Date = { Date() }
}

let Current = Environment()

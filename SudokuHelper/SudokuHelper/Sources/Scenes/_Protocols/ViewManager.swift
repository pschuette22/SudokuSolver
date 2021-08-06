//
//  ViewManager.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/1/21.
//

import Foundation


protocol ViewManager: AnyObject {
    associatedtype StateChange
    associatedtype ViewState

    var state: ViewState { get }
}

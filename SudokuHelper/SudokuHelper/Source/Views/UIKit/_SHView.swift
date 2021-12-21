//
//  SHView.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/20/21.
//

import UIKit

class SHView<State: ViewState>: UIView {
    func render(_ state: State) {
        fatalError("render(_ state:) was not overridden")
    }
}

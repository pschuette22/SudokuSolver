//
//  SHView.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/20/21.
//

import UIKit

protocol StateDrivenView: UIView {
    associatedtype ViewState
    func render(_ state: ViewState)
}

class BaseView<State: ViewState>: UIView, StateDrivenView {
    func render(_ state: State) {
        Logger.log(.error, message: "render(_ state:) was not overridden")
    }
}

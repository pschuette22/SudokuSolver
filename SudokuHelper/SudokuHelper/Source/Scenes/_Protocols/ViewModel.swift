//
//  ViewModel.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/1/21.
//

import Foundation
import Combine

class ViewModel<State: ViewState> {
    @Published
    private(set) var state: State
    
    required init(initialState state: State) {
        self.state = state
    }
}

extension ViewModel {
    func update(_ changeHandler: @escaping (inout State) -> Void) {
        var mutatingState = self.state
        changeHandler(&mutatingState)
        self.state = mutatingState
    }
}

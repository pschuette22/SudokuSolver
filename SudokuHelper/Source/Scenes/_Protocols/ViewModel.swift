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
    var state: State
    
    init(initialState state: State) {
        self.state = state
    }
}

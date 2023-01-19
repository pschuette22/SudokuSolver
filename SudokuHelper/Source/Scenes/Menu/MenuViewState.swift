//
//  MenuViewState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/6/22.
//

import Foundation

struct MenuViewState: ViewState {
    enum Option: Hashable {
        case scan
        case speedTest
        case demo
//        case settings
    }
    
    var options: [Option] {
        [
            .scan,
            .speedTest,
            .demo,
//            .settings
        ]
    }
}

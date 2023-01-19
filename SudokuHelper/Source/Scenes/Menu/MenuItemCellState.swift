//
//  MenuItemCellState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/6/22.
//

import Foundation

struct MenuItemCellState: ViewState {
    let option: MenuViewState.Option

    var displayTitle: String {
        switch option {
        case .scan:
            return "Scan Sudoku"
        case .speedTest:
            return "Speed Test"
//        case .settings:
//            return "Settings"
        }
    }
}

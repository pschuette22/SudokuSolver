//
//  InputControlBarViewState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/22/21.
//

import Foundation
import CoreGraphics

struct InputControlBarViewState: ViewState {
    private(set) var inputControlStates: [InputControlViewState]
    private(set) var controlsPerLine: Int
    let verticalSpacing: CGFloat
    let horizontalSpacing: CGFloat
    
    init(
        inputControlStates: [InputControlViewState] = [
            .init(.digit(1, found: nil, isEnabled: true)),
            .init(.digit(2, found: nil, isEnabled: true)),
            .init(.digit(3, found: nil, isEnabled: true)),
            .init(.digit(4, found: nil, isEnabled: true)),
            .init(.digit(5, found: nil, isEnabled: true)),
            .init(.digit(6, found: nil, isEnabled: true)),
            .init(.digit(7, found: nil, isEnabled: true)),
            .init(.digit(8, found: nil, isEnabled: true)),
            .init(.digit(9, found: nil, isEnabled: true)),
            .init(.eraser),
            .init(.pen),
        ],
        controlsPerLine: Int = 6,
        verticalSpacing: CGFloat = 8,
        horizontalSpacing: CGFloat = 8
    ) {
        self.inputControlStates = inputControlStates
        self.controlsPerLine = controlsPerLine
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
    }
}

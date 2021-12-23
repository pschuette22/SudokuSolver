//
//  InputControlViewState.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/21/21.
//

import Foundation


struct InputControlViewState: ViewState {
    enum ControlType: Hashable {
        enum InputType: Hashable {
            case digitFirst
            case cellFirst
        }

        case digit(Int, found: Int?, isEnabled: Bool)
        case eraser
        case pen
        case pencil
        case inputToggle(InputType)
    }
    
    private(set) var controlType: ControlType
    private(set) var isSelected: Bool
    
    init(
        _ controlType: ControlType,
        isSelected: Bool = false
    ) {
        self.controlType = controlType
        self.isSelected = isSelected
    }
}

// MARK: - Transactions

extension InputControlViewState {
    mutating
    func set(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    mutating
    func update(controlType newControlType: ControlType) {
        if
            case .inputToggle = self.controlType,
            case .inputToggle = newControlType
        {
            self.controlType = newControlType
            return
        }
        
        if
            Set<ControlType>([.pen, .pencil]) == Set<ControlType>([self.controlType, newControlType])
        {
            self.controlType = newControlType
            return
        }
        
        Logger.log(
            .error,
            message: "Invalid control type update attempted.",
            params: ["current": self.controlType, "new": newControlType]
        )
    }
    
}

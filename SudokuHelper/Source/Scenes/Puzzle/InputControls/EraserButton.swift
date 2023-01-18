//
//  EraserButton.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 11/28/22.
//

import Foundation
import UIKit

final class EraserButton: UIButton {
    required init(configuration: Configuration, frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setImage(.init(named: "Eraser", in: .main, with: nil), for: .normal)
        isSelected = configuration.isSelected
        InputControlButtonDecorator.decorate(self, with: .puzzleInputControl())
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EraserButton {
    struct Configuration: Equatable {
        var isSelected: Bool
    }
}

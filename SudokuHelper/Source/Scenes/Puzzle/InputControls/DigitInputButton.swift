//
//  DigitInputControl.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 11/28/22.
//

import Foundation
import UIKit

final class DigitInputButton: UIButton {
    let digit: Int

    required init(configuration: Configuration, frame: CGRect = .zero) {
        self.digit = configuration.digit

        super.init(frame: frame)
        setTitle("\(configuration.digit)", for: .normal)
        isSelected = configuration.isSelected
        InputControlButtonDecorator.decorate(self, with: .puzzleInputControl())
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(configuration: Configuration) {
        self.isSelected = configuration.isSelected
    }
}

extension DigitInputButton {
    struct Configuration: Equatable {
        let digit: Int
        var discovered: Int
        var isSelected: Bool
        
        init(digit: Int, discovered: Int, isSelected: Bool = false) {
            assert((1...9).contains(digit))
            self.digit = digit
            assert(discovered <= 9)
            self.discovered = discovered
            self.isSelected = isSelected
        }
    }
}

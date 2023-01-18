//
//  InputOrderButton.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 11/28/22.
//

import Foundation
import UIKit

final class InputOrderButton: UIButton {
    required init(configuration: Configuration, frame: CGRect = .zero) {
        super.init(frame: frame)
        titleLabel?.numberOfLines = 2
        titleLabel?.lineBreakMode = .byWordWrapping
        render(configuration)
        InputControlButtonDecorator.decorate(self, with: .puzzleInputControl())
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(_ configuration: Configuration) {
        switch configuration.inputOrder {
        case .cellFirst:
            setTitle(Strings.cellFirstTitle, for: .normal)
        case .digitFirst:
            setTitle(Strings.digitFirstTitle, for: .normal)
        }
    }
}

extension InputOrderButton {
    enum InputOrder: Equatable {
        case cellFirst
        case digitFirst
    }

    struct Configuration: Equatable {
        var inputOrder: InputOrder
    }
}

// TODO: Localize strings?
extension InputOrderButton {
    enum Strings {
        static let cellFirstTitle = "Cell First"
        static let digitFirstTitle = "Digit First"
    }
}

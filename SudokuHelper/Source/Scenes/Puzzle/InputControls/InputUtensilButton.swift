//
//  InputUtensilButton.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 11/28/22.
//

import Foundation
import UIKit

final class InputUtensilButton: UIButton {
    private(set) var utensil: InputUtensil

    required init(configuration: Configuration, frame: CGRect = .zero) {
        utensil = configuration.utensil
        super.init(frame: frame)
        
        setImage(
            .init(named: "Pen", in: .main, with: nil)?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        
        render(with: configuration)
        var buttonConfiguration = UIButton.Configuration.puzzleInputControl()
        buttonConfiguration.imageColorTransformer = .init({ [weak self] _ in
            let utensil = self?.utensil ?? .pen

            return utensil.tint
        })

        InputControlButtonDecorator.decorate(self, with: buttonConfiguration)
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(with configuration: Configuration) {
        utensil = configuration.utensil
        imageView?.setNeedsLayout()
    }
}

extension InputUtensilButton {
    enum InputUtensil {
        // Input type used when answers should be set as final
        case pen
        // Input type used when answers should be set a possible
        case pencil
        
        var tint: UIColor {
            switch self {
            case .pen:
                return .black
            case .pencil:
                return .gray
            }
        }
    }

    struct Configuration: Equatable {
        var utensil: InputUtensil
    }
}

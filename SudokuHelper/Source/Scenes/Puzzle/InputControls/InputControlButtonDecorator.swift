//
//  InputControlButtonDecorator.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/20/22.
//

import Foundation
import UIKit

extension UIButton.Configuration {
    static func puzzleInputControl() -> Self {
        var configuration = UIButton.Configuration.bordered()
        configuration.cornerStyle = .fixed
        // TODO: theming based on device theme
        configuration.baseBackgroundColor = .white
        configuration.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        configuration.imagePadding = .init(12)
        return configuration
    }
}

enum InputControlButtonDecorator {
    static func decorate(_ button: UIButton, with configuration: UIButton.Configuration) {
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 8
        button.imageView?.contentMode = .scaleAspectFit
        button.configuration = configuration
    }
}

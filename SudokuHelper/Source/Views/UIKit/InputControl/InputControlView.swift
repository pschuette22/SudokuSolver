//
//  InputControlView.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/21/21.
//

import Foundation
import CoreGraphics
import UIKit

final class InputControlView: BaseView<InputControlViewState> {
    private(set) var renderedType: InputControlViewState.ControlType!
    private let contentView = UIView()
    private let primaryLabel = UILabel()
    private let secondaryLabel = UILabel()
    private static let defaultSecondaryLabelPadding: CGFloat = 4
    private let imageView = UIImageView()
    private var imageHeightConstraint: NSLayoutConstraint!
    private var imageWidthConstraint: NSLayoutConstraint!
    private static let selectedImageScale: CGFloat = 0.8
    private static let unselectedImageScale: CGFloat = 0.6
    
    init(frame: CGRect = .zero, initialState: InputControlViewState) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupSubviews()
        render(initialState)
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func render(_ state: InputControlViewState) {
        self.renderedType = state.controlType

        switch state.controlType {
        case let .digit(digit, found, isEnabled):
            primaryLabel.text = "\(digit)"
            primaryLabel.alpha = 1
            if let found = found {
                secondaryLabel.text = "\(found)"
                secondaryLabel.alpha = 1
            } else {
                secondaryLabel.alpha = 0
            }
            contentView.backgroundColor = isEnabled ? .white : .gray
            
            if state.isSelected {
                primaryLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
            } else {
                primaryLabel.font = UIFont.preferredFont(forTextStyle: .title1)
            }
            imageView.alpha = 0
            break
        case .eraser:
            imageView.image = UIImage(named: "Eraser")
            if state.isSelected {
                imageHeightConstraint = imageHeightConstraint.set(multiplier: Self.selectedImageScale)
            } else {
                imageHeightConstraint = imageHeightConstraint.set(multiplier: Self.unselectedImageScale)
            }
            imageView.alpha = 1
            primaryLabel.alpha = 0
            secondaryLabel.alpha = 0
        case .pen, .pencil:
            var image = UIImage(named: "Pen")?.withRenderingMode(.alwaysTemplate)
            if case .pen = state.controlType {
                image = image?.withTintColor(.black)
            } else {
                image = image?.withTintColor(.gray)
            }
            
            imageView.image =  image
            imageView.alpha = 1
            primaryLabel.alpha = 0
            secondaryLabel.alpha = 0

        case .inputToggle:
            Logger.log(.debug, message: "Input control render missing", params: ["type": state.controlType])
        }
    }
}

// MARK: - Subviews

extension InputControlView {
    private func setupSubviews() {
        addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        
        contentView.addSubview(primaryLabel)
        primaryLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        primaryLabel.adjustsFontSizeToFitWidth = true
        primaryLabel.minimumScaleFactor = 0.25
        primaryLabel.alpha = 0
        primaryLabel.textAlignment = .center
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            primaryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            primaryLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            primaryLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            primaryLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
        ])
        
        contentView.addSubview(secondaryLabel)
        secondaryLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        secondaryLabel.adjustsFontSizeToFitWidth = true
        secondaryLabel.minimumScaleFactor = 0.25
        secondaryLabel.alpha = 0
        secondaryLabel.textAlignment = .center
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: (2 * Self.defaultSecondaryLabelPadding)),
            secondaryLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Self.defaultSecondaryLabelPadding),
            secondaryLabel.leftAnchor.constraint(equalTo: primaryLabel.rightAnchor, constant: Self.defaultSecondaryLabelPadding),
        ])
        
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: Self.unselectedImageScale)
        imageWidthConstraint = imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: Self.unselectedImageScale)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageHeightConstraint,
            imageWidthConstraint,
        ])
    }
}

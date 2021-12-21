//
//  CellUIView.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/20/21.
//

import UIKit

final class CellUIView: SHView<CellViewState> {
    /// Position of the cell within the puzzle
    let position: Cell.Position
    private lazy var contentView = UIView(frame: .init(origin: .zero, size: frame.size))
    /// Label displaying solved value
    private lazy var valueLabel = UILabel()
    /// Spacing between possibility labels
    private static let possibilitySpacing: CGFloat = 2
    /// Dictionary mapping label displaying possibility to value
    private var possibilityLabels = [Int: UILabel]()
    
    init(frame: CGRect = .zero, position: Cell.Position) {
        self.position = position

        super.init(frame: frame)

        backgroundColor = .white
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func render(_ state: CellViewState) {
        if let value = state.value {
            valueLabel.text = String(value)
            valueLabel.alpha = 1
            _ = possibilityLabels.mapValues { $0.alpha = 0 }
            if state.isValueBold {
                valueLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
            } else {
                valueLabel.font = UIFont.preferredFont(forTextStyle: .title1)
            }
        } else {
            valueLabel.alpha = 0
            possibilityLabels.forEach { $0.value.alpha = state.possibilities.contains($0.key) ? 1 : 0 }
        }
        
        if state.isFocused {
            self.contentView.backgroundColor = .cyan.withAlphaComponent(0.3)
        } else if state.isHighlighted {
            self.contentView.backgroundColor = .yellow.withAlphaComponent(0.3)
        } else {
            self.contentView.backgroundColor = .white
        }
    }
}

// MARK: - Subviews

extension CellUIView {
    private func setupSubviews() {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentView.heightAnchor.constraint(equalTo: self.heightAnchor),
            contentView.widthAnchor.constraint(equalTo: self.widthAnchor),
        ])
        
        // Setup possibilities
        (1...9).forEach { possibility in
            let label = UILabel()
            label.alpha = 0
            label.numberOfLines = 1
            label.font = UIFont.preferredFont(forTextStyle: .footnote)
            label.adjustsFontSizeToFitWidth = true
            label.translatesAutoresizingMaskIntoConstraints = false
            label.minimumScaleFactor = 0.5
            label.textAlignment = .center
            label.textColor = .gray
            label.text = "\(possibility)"
            contentView.addSubview(label)
            possibilityLabels[possibility] = label
            position(label, for: possibility)
        }
        
        contentView.addSubview(valueLabel)
        valueLabel.alpha = 0
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        valueLabel.minimumScaleFactor = 0.5
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textColor = .black
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.possibilitySpacing),
            valueLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Self.possibilitySpacing),
            valueLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Self.possibilitySpacing),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Self.possibilitySpacing),
        ])
    }
    
    
    /// Constrain the possibility label within the cell view
    /// - Parameters:
    ///   - label: Label which requires positioning
    ///   - possibility: Possibility this label depicts
    private func position(_ label: UILabel, for possibility: Int) {
        var constraints = [NSLayoutConstraint]()
        
        // Top constraint
        if possibility <= 3 /*One of 1,2,3*/ {
            constraints.append(label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.possibilitySpacing))
        } else if let topSibling = possibilityLabels[possibility - 3] {
            constraints.append(label.topAnchor.constraint(equalTo: topSibling.bottomAnchor, constant: Self.possibilitySpacing))
            constraints.append(label.heightAnchor.constraint(equalTo: topSibling.heightAnchor))
        }
        
        // Leading constraint
        if possibility % 3 == 1 /*One of 1,4,7*/ {
            constraints.append(label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Self.possibilitySpacing))
        } else if let leftSibling = possibilityLabels[possibility-1] {
            constraints.append(label.leftAnchor.constraint(equalTo: leftSibling.rightAnchor, constant: Self.possibilitySpacing))
            constraints.append(label.widthAnchor.constraint(equalTo: leftSibling.widthAnchor))
        }
        
        // NOTE: Right and bottom constraints are only applicable to edge cells
        
        // Trailing constraint
        if possibility % 3 == 0 /*One of 3,6,9*/ {
            constraints.append(label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Self.possibilitySpacing))
        }
        
        // Bottom constraint
        if possibility > 6 /*One of 7,8,9*/ {
            constraints.append(label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Self.possibilitySpacing))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}

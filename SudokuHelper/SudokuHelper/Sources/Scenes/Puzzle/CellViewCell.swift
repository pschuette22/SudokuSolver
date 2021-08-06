//
//  CellViewCell.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/1/21.
//

import Foundation
import UIKit


final class CellViewCell: UICollectionViewCell, StatefulView, Registerable {
    static let reuseIdentifier = "com.peteschuette.sudoku-helper.CellViewCell"
    private static let standardMargin: CGFloat = 2
    typealias ViewState = CellViewState
    
    private var valueLabel: UILabel!
    private var possibilityLabels = [UILabel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubviews()
    }
}

// MARK: - View setup
private extension CellViewCell {
    func initSubviews() {
        self.backgroundColor = .white
        // Setup the main value label
        valueLabel = UILabel()
        valueLabel.textColor = .black
        valueLabel.font = .preferredFont(forTextStyle: .title1)
        valueLabel.alpha = 0
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.1
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 1
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        // Setup the stack views
        let possibilityStack = UIStackView()
        possibilityStack.alignment = .fill
        possibilityStack.distribution = .fillEqually
        possibilityStack.axis = .vertical
        possibilityStack.backgroundColor = .clear
        possibilityStack.spacing = Self.standardMargin
        possibilityStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        possibilityStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(possibilityStack)
        
        for i in 0..<3 {
            let possibilitySubStack = UIStackView()
            possibilitySubStack.alignment = .fill
            possibilitySubStack.distribution = .fillEqually
            possibilitySubStack.axis = .horizontal
            possibilitySubStack.backgroundColor = .clear
            possibilitySubStack.spacing = Self.standardMargin
            possibilitySubStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            possibilitySubStack.translatesAutoresizingMaskIntoConstraints = false
            for j in 0..<3 {
                let label = UILabel()
                label.alpha = 0
                label.font = .preferredFont(forTextStyle: .footnote)
                label.textColor = .darkGray
                label.text = String(i*3 + j + 1)
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.1
                label.textAlignment = .center
                label.numberOfLines = 1
                label.translatesAutoresizingMaskIntoConstraints = false
                possibilitySubStack.addArrangedSubview(label)
                possibilityLabels.append(label)
            }
            possibilityStack.addArrangedSubview(possibilitySubStack)
        }
        
        NSLayoutConstraint.activate([
            possibilityStack.topAnchor.constraint(equalTo: topAnchor),
            possibilityStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            possibilityStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            possibilityStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

// MARK: - CellViewCell+StatefulView
extension CellViewCell {
    @discardableResult
    func render(_ state: CellViewState) -> CellViewCell {
        
        if let value = state.value {
            possibilityLabels.forEach { $0.alpha = 0 }
            valueLabel.text = String(value)
            valueLabel.alpha = 1
        } else {
            valueLabel.alpha = 0
            for i in 0..<9 {
                possibilityLabels[i].alpha = state.possibilities.contains(i+1) ? 1 : 0
            }
        }
        // TODO: deal with highlighting and focus
        return self
    }
}

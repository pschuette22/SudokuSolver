//
//  InputControlBar.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/22/21.
//

import Foundation
import UIKit

protocol InputControlBarViewDelegate: AnyObject {
    func didTapInputControl(_ inputControl: InputControlViewState.ControlType)
}

final class InputControlBarView: SHView<InputControlBarViewState> {
    weak var delegate: InputControlBarViewDelegate?
    private static var maximumSize: CGSize = .init(width: 65, height: 65)
    
    private lazy var verticalControlStack: UIStackView = {
        var stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stack
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func render(_ state: InputControlBarViewState) {
        precondition(state.controlsPerLine > 0)
        
        verticalControlStack.spacing = state.verticalSpacing
        
        var inputControlStates = state.inputControlStates
        var cursor = IndexPath(item: 0, section: 0)

        while !inputControlStates.isEmpty {
            let inputControlState = inputControlStates.removeFirst()
            
            var horizontalStack: UIStackView
            if let existingView = verticalControlStack.arrangedSubviews[safe: cursor.section] as? UIStackView {
                if existingView.arrangedSubviews.count > state.controlsPerLine {
                    (state.controlsPerLine..<existingView.arrangedSubviews.count).forEach { _ in
                        existingView.arrangedSubviews.last?.removeFromSuperview()
                    }
                }

                horizontalStack = existingView
            } else {
                horizontalStack = UIStackView()
                horizontalStack.axis = .horizontal
                horizontalStack.alignment = .center
                horizontalStack.distribution = .equalSpacing
                horizontalStack.spacing = state.horizontalSpacing
                horizontalStack.translatesAutoresizingMaskIntoConstraints = false
                verticalControlStack.addArrangedSubview(horizontalStack)
            }
            
            if let existingInputControl = horizontalStack.arrangedSubviews[safe: cursor.item] as? InputControlView {
                existingInputControl.render(inputControlState)
            } else {
                let inputControl = makeInputControl(with: inputControlState)
                horizontalStack.addArrangedSubview(inputControl)
                
                if
                    cursor.item > 0,
                    let leftSibling = (verticalControlStack.arrangedSubviews[safe: cursor.section] as? UIStackView)?
                        .arrangedSubviews[safe: cursor.item-1]
                {
                    NSLayoutConstraint.activate([
                        inputControl.widthAnchor.constraint(equalTo: leftSibling.widthAnchor)
                    ])
                } else if
                    cursor.section > 0,
                    let topLeftSibling = (verticalControlStack.arrangedSubviews[safe: cursor.section-1] as? UIStackView)?
                            .arrangedSubviews[safe: 0]
                {
                    NSLayoutConstraint.activate([
                        inputControl.widthAnchor.constraint(equalTo: topLeftSibling.widthAnchor)
                    ])
                }
            }
            
            if inputControlStates.isEmpty { break }
            
            cursor.item = cursor.item + 1
            if cursor.item == state.controlsPerLine {
                // next line
                cursor = IndexPath(item: 0, section: cursor.section + 1)
            }
        }
        
        if verticalControlStack.arrangedSubviews.count-1 > cursor.section {
            // Remove the trailing sections
            let horizontalRowCount = verticalControlStack.arrangedSubviews.count
            (cursor.section ..< horizontalRowCount-1).forEach { _ in
                verticalControlStack.arrangedSubviews.last?.removeFromSuperview()
            }
        }
    }
    
    private func makeInputControl(with state: InputControlViewState) -> InputControlView {
        let inputControlView = InputControlView(initialState: state)
        inputControlView.layer.cornerRadius = 4
        inputControlView.layer.borderWidth = 2
        inputControlView.layer.borderColor = UIColor.black.cgColor
        inputControlView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapInputControl(_:)))
        )
        
        NSLayoutConstraint.activate([
            inputControlView.heightAnchor.constraint(lessThanOrEqualToConstant: Self.maximumSize.height),
            inputControlView.heightAnchor.constraint(equalTo: inputControlView.widthAnchor),
        ])
        
        return inputControlView
    }
}

// MARK: - Tap handling

extension InputControlBarView {
    @objc
    private func didTapInputControl(_ sender: UITapGestureRecognizer?) {
        guard
            let inputControlView = sender?.view as? InputControlView
        else {
            Logger.log(.error, message: "Failed to convert sender to InputControlView")
            return
        }
        
        delegate?.didTapInputControl(inputControlView.renderedType)
    }
}

// MARK: - Subviews

extension InputControlBarView {
    private func setupSubviews() {
        addSubview(verticalControlStack)
        NSLayoutConstraint.activate([
            verticalControlStack.topAnchor.constraint(equalTo: topAnchor),
            verticalControlStack.leftAnchor.constraint(equalTo: leftAnchor),
            verticalControlStack.rightAnchor.constraint(equalTo: rightAnchor),
            verticalControlStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

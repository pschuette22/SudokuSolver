//
//  InputControlBar.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/20/22.
//

import Combine
import Foundation
import UIKit

// TODO: add a view state
final class InputControlBar: UIView {
    private lazy var digitButtons = (1...9).reduce(into: [Int: DigitInputButton]()) { result, int in
        let button = DigitInputButton(configuration: .init(digit: int, discovered: 0))
            .withTarget(self, action: #selector(didTapControl), for: .touchUpInside)
        result[int] = button
    }
    
    private lazy var inputUtensilButton = InputUtensilButton(configuration: .init(utensil: .pen))
        .withTarget(self, action: #selector(didTapControl), for: .touchUpInside)
    
    private lazy var eraserButton = EraserButton(configuration: .init(isSelected: false))
        .withTarget(self, action: #selector(didTapControl), for: .touchUpInside)
    
    private lazy var inputOrderButton = InputOrderButton(configuration: .init(inputOrder: .digitFirst))
        .withTarget(self, action: #selector(didTapControl), for: .touchUpInside)
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews
extension InputControlBar {
    private enum Constants {
        static let maximumInputControlSize: CGSize = .init(width: 60, height: 60)
        static let minimumInputControlSize: CGSize = .init(width: 30, height: 30)
        static let controlSpacing: CGFloat = 12
    }
    
    private func setupSubviews() {
        digitButtons.forEach { _, digitButton in
            addSubview(digitButton)
        }
        addSubview(inputUtensilButton)
        addSubview(eraserButton)
        addSubview(inputOrderButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // TODO: make a dynamic linecount
        reframeControls(lineCount: 3)
    }
    
    private func reframeControls(lineCount: Int) {
        switch lineCount {
        case 1:
            /*
             * [1][2][3][4][5][6][7][8][9] [P][E][O]
             */
            assertionFailure("Not supported yet, use 3")
        case 2:
            /*
             * [1][2][3][4][5][6]
             * [7][8][9][P][E][O]
             */
            assertionFailure("Not supported yet, use 3")
        case 3:
            /*
             * [1][2][3] [P]
             * [4][5][6] [E]
             * [7][8][9] [O]
             */
            let totalLineSpace = 4 * Constants.controlSpacing
            let availableWidth = frame.width - totalLineSpace
            let controlSideLength = max(min(Constants.maximumInputControlSize.width, availableWidth / 4), Constants.minimumInputControlSize.width)
            (0...2).forEach { y in
                let yOffset = CGFloat(y) * (controlSideLength + Constants.controlSpacing)
                (0...2).forEach { x in
                    let digit = 1 + (y * 3) + x
                    let xOffset = CGFloat(x) * (controlSideLength + Constants.controlSpacing)
                    
                    digitButtons[digit]?.frame = .init(
                        origin: .init(x: xOffset, y: yOffset),
                        size: .init(width: controlSideLength, height: controlSideLength)
                    )
                }
                
                let lastInputControl: UIButton
                switch y {
                case 0:
                    lastInputControl = self.inputUtensilButton
                case 1:
                    lastInputControl = self.eraserButton
                case 2:
                    lastInputControl = self.inputOrderButton
                default:
                    // Wont reach, prefer switch to if/else block
                    assertionFailure("unrecognized input control")
                    return
                }
                // One extra bit of control offset to separate number pad from inputs
                let xOffset = (3 * controlSideLength) + (4 * Constants.controlSpacing)
                lastInputControl.frame = .init(
                    origin: .init(x: xOffset, y: yOffset),
                    size: .init(width: controlSideLength, height: controlSideLength)
                )
            }
            
            frame.size.height = (controlSideLength * 3) + Constants.controlSpacing * 2
        default:
            assertionFailure("unsupported control line count")
        }
    }
    
    static func preferredHeight(given width: CGFloat) -> CGFloat {
        let totalLineSpace = 4 * Constants.controlSpacing
        let availableWidth = width - totalLineSpace
        let controlSideLength = max(min(Constants.maximumInputControlSize.width, availableWidth / 4), Constants.minimumInputControlSize.width)
        
        return (controlSideLength * 3) + (Constants.controlSpacing * 2)
    }
}

// MARK: - Tap Handling

extension InputControlBar {
    @objc
    private func didTapControl(_ sender: UIButton) {
        switch sender {
        case let sender as DigitInputButton:
            print("did tap \(sender.digit)!")
        case let sender as InputUtensilButton:
            print("did tap utensil")
        case let sender as EraserButton:
            print("did tap eraser")
        case let inputOrder as InputOrderButton:
            print("did tap input order")
        default:
            assertionFailure("responded to unrecognized input control")
        }
    }
}

private extension UIButton {
    /// Attach a target inline. This is the same as initializing and calling addTarget(:action:for:)
    func withTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) -> Self {
        addTarget(target, action: action, for: controlEvents)
        return self
    }
}

//
//  PuzzleViewController.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/28/21.
//

import Foundation
import UIKit


protocol PuzzleViewControllerDelegate: AnyObject {
    func didTapCell(at position: Puzzle.Location)
}

final class PuzzleViewController: ViewController<PuzzleViewControllerState, PuzzleViewControllerModel> {
    private static let defaultMargin: CGFloat = 16
    private lazy var puzzleView = PuzzleUIView()
    private lazy var inputControls = InputControlBar()
    private static let inputControlBarPadding: CGFloat = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    // MARK: - Base Functions

    override func setupSubviews() {
        // Input controls
        inputControls.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputControls)

        // Base puzzle view
        // TODO: account iPad
        let minimumSideLength = min(view.frame.width, view.frame.height)
        let puzzleSideLength = minimumSideLength - (Self.defaultMargin * 2)
        puzzleView = PuzzleUIView()
        puzzleView.translatesAutoresizingMaskIntoConstraints = false
        puzzleView.delegate = self
        view.addSubview(puzzleView)
        NSLayoutConstraint.activate([
            puzzleView.widthAnchor.constraint(equalToConstant: puzzleSideLength),
            puzzleView.heightAnchor.constraint(equalTo: puzzleView.widthAnchor),
            puzzleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            puzzleView.topAnchor.constraint(equalTo: view.topAnchor, constant: Self.defaultMargin),
        ])
    }
    
    override func render(_ state: PuzzleViewControllerState) {
        puzzleView.render(state.puzzleViewState)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let xOffset: CGFloat = 36
        let width = view.frame.width - (2 * xOffset)
        let height = InputControlBar.preferredHeight(given: width)
        inputControls.frame = .init(
            origin: .init(
                x: xOffset,
                y: view.frame.height - (36 + height)),
            size: .init(
                width: width,
                height: height
            )
        )
    }
}

// MARK: - PuzzleViewDelegate

extension PuzzleViewController: PuzzleUIViewDelegate {
    func didTapCell(at position: Puzzle.Location) {
        model.didTapCell(at: position)
    }
}

// MARK: - InputControlBarViewDelegate

extension PuzzleViewController: InputControlBarViewDelegate {
    func didTapInputControl(_ inputControl: InputControlViewState.ControlType) {
        Logger.log(.debug, message: "Did tap input control", params: ["control": inputControl])
    }
}

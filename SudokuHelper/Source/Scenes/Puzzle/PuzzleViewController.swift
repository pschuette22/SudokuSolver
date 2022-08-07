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
    private lazy var inputControlBar = InputControlBarView()
    private static let inputControlBarPadding: CGFloat = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        inputControlBar.invalidateIntrinsicContentSize()
        inputControlBar.render(model.state.inputControlBarState)
    }
    // MARK: - Base Functions

    override func setupSubviews() {
        // Input controls
        inputControlBar.translatesAutoresizingMaskIntoConstraints = false
        inputControlBar.delegate = self
        view.addSubview(inputControlBar)
        NSLayoutConstraint.activate([
            inputControlBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputControlBar.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2 * Self.inputControlBarPadding),
            inputControlBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Self.inputControlBarPadding)
        ])
        
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
        inputControlBar.render(state.inputControlBarState)
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

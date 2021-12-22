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

final class PuzzleViewController: ViewController<PuzzleViewState, PuzzleViewControllerModel> {
    private static let defaultMargin: CGFloat = 16
    private lazy var puzzleView = PuzzleUIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    // MARK: - Base Functions

    override func setupSubviews() {
        // Base puzzle view
        // TODO: account for controls
        let minimumSideLength = min(view.frame.width, view.frame.height)
        let puzzleSideLength = minimumSideLength - (Self.defaultMargin * 2)
        puzzleView = PuzzleUIView()
        puzzleView.translatesAutoresizingMaskIntoConstraints = false
        puzzleView.delegate = self
        view.addSubview(puzzleView)
        
        NSLayoutConstraint.activate([
            puzzleView.widthAnchor.constraint(equalToConstant: puzzleSideLength),
            puzzleView.heightAnchor.constraint(equalToConstant: puzzleSideLength),
            puzzleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            puzzleView.topAnchor.constraint(equalTo: view.topAnchor, constant: Self.defaultMargin)
        ])
    }
    
    override func render(_ state: PuzzleViewState) {
        puzzleView.render(state)
    }
}

// MARK: - PuzzleViewDelegate

extension PuzzleViewController: PuzzleUIViewDelegate {
    func didTapCell(at position: Puzzle.Location) {
        model.didTapCell(at: position)
    }
}

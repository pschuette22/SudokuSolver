//
//  PuzzleUIView.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/20/21.
//

import UIKit

protocol PuzzleViewDelegate: AnyObject {
    func didTapCell(at position: Puzzle.Location)
}

final class PuzzleUIView: SHView<PuzzleViewState> {
    typealias X = Int
    typealias Y = Int

    private static let cellIndexes = 0...8
    private static let interGroupSpacing: CGFloat = 4
    private static let interCellSpacing: CGFloat = 2
    weak var delegate: PuzzleViewDelegate?
    private var cellViews = [Y: [X: CellUIView]]()
 
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func render(_ state: PuzzleViewState) {
        state.cellStates.flattened.forEach { cellState in
            let position = cellState.location
            guard let cellView = cellViews[position.y]?[position.x] else {
                assertionFailure("Failed to render cell at \(position)")
                return
            }

            cellView.render(cellState)
        }
    }
    
}

// MARK: - Subviews

private extension PuzzleUIView {
    func setupSubViews() {
        backgroundColor = .black
        
        Self.cellIndexes.forEach { y in
            cellViews[y] = [X: CellUIView]()
            Self.cellIndexes.forEach { x in
                let cellView = CellUIView(position: (x: x, y: y))
                cellView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(cellView)
                cellViews[y]?[x] = cellView

                position(cellView, at: (x: x, y: y))
            }
        }
    }
    
    
    /// Constrain the position of the cell within the puzzle
    /// - Parameters:
    ///   - cell: ```CellUIView```
    ///   - location: X,Y location within puzzle. Values should be within 1 and 9
    func position(_ cell: CellUIView, at location: (x: X, y: Y)) {
        precondition(Self.cellIndexes.contains(location.x))
        precondition(Self.cellIndexes.contains(location.y))

        var constraints = [NSLayoutConstraint]()
        // Top constraint
        if location.y == 0 {
            constraints.append(cell.topAnchor.constraint(equalTo: topAnchor, constant: Self.interGroupSpacing))
        } else if let topSibling = cellViews[location.y-1]?[location.x] {
            let spacing = location.y % 3 == 0 ? Self.interGroupSpacing : Self.interCellSpacing
            constraints.append(cell.topAnchor.constraint(equalTo: topSibling.bottomAnchor, constant: spacing))
            constraints.append(cell.heightAnchor.constraint(equalTo: topSibling.heightAnchor))
        }
        
        // Leading constraint
        if location.x == 0 {
            constraints.append(cell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.interGroupSpacing))
        } else if let leftSibling = cellViews[location.y]?[location.x-1] {
            let spacing = location.x % 3 == 0 ? Self.interGroupSpacing : Self.interCellSpacing
            constraints.append(cell.leadingAnchor.constraint(equalTo: leftSibling.trailingAnchor, constant: spacing))
            constraints.append(cell.widthAnchor.constraint(equalTo: leftSibling.widthAnchor))
        }
        
        if location.y == 8 {
            constraints.append(cell.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.interGroupSpacing))
        }
        
        if location.x == 8 {
            constraints.append(cell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.interGroupSpacing))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}



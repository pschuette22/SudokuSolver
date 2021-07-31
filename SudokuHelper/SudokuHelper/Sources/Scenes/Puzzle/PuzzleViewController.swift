//
//  PuzzleViewController.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/28/21.
//

import Foundation
import UIKit


final class PuzzleViewController: UIViewController {
    
    private lazy var collectionView = UICollectionView(
        frame: parent?.view.frame ?? .zero,
        collectionViewLayout: Self.buildPuzzleCollectionViewLayout()
    )
    var manager: PuzzleViewManager!

}


// MARK: - Lifecycle
extension PuzzleViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubViews()
    }
}


// MARK: - View setup
private extension PuzzleViewController {
    
    func setupSubViews() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .red
    }
    
    func setupCollectionViewLayout() {
//        collectionView.collectionViewLayout =
    }
    
}


// MARK: - Static builders
private extension PuzzleViewController {
    
    static func buildPuzzleCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewLayout()
        return layout
    }
    
}

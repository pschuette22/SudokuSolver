//
//  PuzzleViewController.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/28/21.
//

import Foundation
import UIKit


final class PuzzleViewController: UIViewController {
    enum Section: CaseIterable {
        case puzzle
//        case controls
    }
    enum CollectionCell {
        case puzzleCell(_ cell: CellViewState)
    }
    
    private var collectionView: UICollectionView!
    var manager: PuzzleViewManager!
    var dataSource: UICollectionViewDiffableDataSource<Section, CollectionCell>!
    
    private var snapshot: NSDiffableDataSourceSnapshot<Section, CollectionCell> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionCell>()
        snapshot.appendSections([.puzzle])
        snapshot.appendItems(manager.state.cellStates.joined().map({ .puzzleCell($0) }))
        
        return snapshot
    }
}


// MARK: - Lifecycle
extension PuzzleViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dataSource.apply(snapshot, animatingDifferences: false)
        // TODO: setup combine listeners
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // TODO: remove combine
    }
}


// MARK: - View setup
private extension PuzzleViewController {
    
    func setupCollectionView() {
        let layout = setupCollectionViewLayout()
        self.collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        // cell registration
        collectionView.register(CellViewCell.self)
        setupDataSource()
    }
    
    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CellViewCell, CellViewState> { viewCell, indexPath, state in
            viewCell.render(state)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, CollectionCell>(
            collectionView: collectionView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, collectionCell: PuzzleViewController.CollectionCell) -> UICollectionViewCell? in
            switch collectionCell {
            case let .puzzleCell(cellViewState):
                return collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: cellViewState
                )
            }
        }
    }
    
    @discardableResult
    func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let spacing = CGFloat(2)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let fullRowSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(contentSize.width/9)
            )
            let partialRowSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1)
            )
            let partialRow = NSCollectionLayoutGroup.horizontal(
                layoutSize: partialRowSize,
                subitem: item,
                count: 3
            )
            partialRow.interItemSpacing = .fixed(spacing)
            let row = NSCollectionLayoutGroup.horizontal(
                layoutSize: fullRowSize,
                subitem: partialRow,
                count: 3
            )
            row.interItemSpacing = .fixed(2 * spacing)
            
            let rowCollectionSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1/3)
            )
            let rowCollection = NSCollectionLayoutGroup.vertical(
                layoutSize: rowCollectionSize,
                subitem: row,
                count: 3
            )
            rowCollection.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: rowCollection)
            section.decorationItems = [ElementKind.background.decoratorItem]
            section.interGroupSpacing = 2 * spacing

            // TODO: space based on screen size for iPad
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 2 * spacing,
                leading: 2 * spacing,
                bottom: 2 * spacing,
                trailing: 2 * spacing
            )
            
            return section
        }
        
        
        layout.register(
            BlackBackgroundDecoratorView.self,
            forDecorationViewOfKind: ElementKind.background.rawValue
        )
        
        return layout
    }

}

// MARK: -  Decorators
private extension PuzzleViewController {
    enum ElementKind: String {
        case background = "ElementKind.background"
        
        var decoratorItem: NSCollectionLayoutDecorationItem {
            switch self {
            case .background:
                return NSCollectionLayoutDecorationItem.background(
                    elementKind: ElementKind.background.rawValue)
            }
        }
    }
}

// MARK: - BlackBackgroundDecoratorView
final class BlackBackgroundDecoratorView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - PuzzleViewController.Cell+Equatable
extension PuzzleViewController.CollectionCell: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .puzzleCell(cell):
            hasher.combine(cell.hashValue)
        }
    }
}

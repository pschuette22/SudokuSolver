//
//  MenuViewController.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/6/22.
//

import Foundation
import UIKit

class MenuViewController: ViewController<MenuViewState, MenuViewControllerModel> {
    private var collectionViewLayout: UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )
    private lazy var dataSource: DataSource = {
        Self.makeDataSource(for: collectionView)
    }()
    
    required init(model: MenuViewControllerModel) {
        super.init(model: model)
    }
    
    override func setupSubviews() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }

    override func render(_ state: MenuViewState) {
        dataSource.apply(generateSnapshot(from: state))
    }
}

// MARK: - DataSource

extension MenuViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource
    enum Section: Hashable {
        case menuItems
    }
    
    enum Item: Hashable {
        case menuItem(MenuItemCellState)
    }
    
    private static func makeDataSource(for collectionView: UICollectionView) -> DataSource<Section, Item> {
        DataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .menuItem(let state):
                return MenuItemCollectionCell.configured(for: collectionView, at: indexPath, withState: state)
            }
        }
    }
    
    private func generateSnapshot(from state: MenuViewState) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.menuItems])
        snapshot.appendItems(
            state.options.map {
                .menuItem(model.cellModel(for: $0))
            },
            toSection: .menuItems
        )
        
        return snapshot
    }
}

// MARK: - UICollectionViewDelegate

extension MenuViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard collectionView == self.collectionView else { return }

        model.didTapItem(at: indexPath)
    }
}

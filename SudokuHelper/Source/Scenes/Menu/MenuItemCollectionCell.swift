//
//  MenuItemCollectionCell.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/6/22.
//

import Foundation
import UIKit

final class MenuItemCollectionCell: UICollectionViewCell, Registerable, StateDrivenView {
    typealias ViewState = MenuItemCellState
    static let reuseIdentifier: String = "MenuItemCollectionCell"

    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    @available(*, unavailable, message: "storyboard / xib not supported")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(_ state: MenuItemCellState) {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.text = state.displayTitle
    }
    
    private func setupSubviews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
}

// MARK: - Static Initializer
extension MenuItemCollectionCell {
    static func configured(
        for collectionView: UICollectionView,
        at indexPath: IndexPath,
        withState state: ViewState
    ) -> MenuItemCollectionCell? {
        guard
            let cell = collectionView.dequeueRegistered(MenuItemCollectionCell.self, for: indexPath)
        else {
            fatalError("Failed to dequeue cell")
        }
        
        cell.render(state)
        return cell
    }
}



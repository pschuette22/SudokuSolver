//
//  Registerable.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/1/21.
//

import Foundation
import UIKit

protocol Registerable: UICollectionViewCell {
    static var reuseIdentifier: String { get }
}

extension UICollectionView {
    func register(_ cellType: Registerable.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueRegistered<T: Registerable>(_ cellType: T.Type, for indexPath: IndexPath) -> T? {
        register(cellType)
        return dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T
    }
}

//
//  UIEdgeInsets+Extensions.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 2/19/22.
//

import UIKit

extension UIEdgeInsets {
    init(_ value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
    
    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}


//
//  StatefulView.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/1/21.
//

import Foundation
import UIKit

protocol StatefulView: UIView {
    associatedtype ViewState
    
    @discardableResult
    func render(_ state: ViewState) -> Self
}

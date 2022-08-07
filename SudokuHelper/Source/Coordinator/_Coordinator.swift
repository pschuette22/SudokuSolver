//
//  Coordinator.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    associatedtype Scene

    var navigationController: UINavigationController { get }
    
    func start()
    
    func present(_ scene: Scene)
}


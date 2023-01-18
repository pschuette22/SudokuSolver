//
//  Coordinator.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation
import UIKit

protocol Coordinator: NSObject, NavigationStackListener {
    var identifier: UUID { get }
    var navigationController: NavigationController { get }
    var parent: ParentCoordinator? { get set }
    func start()
}

extension Coordinator {
    func registerAsNavigationStackListener() {
        navigationController.register(navigationStackListener: self)
    }

    func navigationStackDidChange() {
        if navigationController
            .viewControllers
            .contains(
                where: { ($0 as? CoordinatedViewController)?.coordinatorIdentifier == identifier }
            )
        { return }
        
        // If the navigation controller doesn't contain any view controllers
        // This coordinator coordinates, assume we have completed
        parent?.didComplete(self)
    }
}

protocol ParentCoordinator: Coordinator {
    var children: [Coordinator] { get set }
}

extension ParentCoordinator {
    func didComplete(_ child: Coordinator) {
        children.removeAll { $0 == child }
    }
}

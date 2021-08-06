//
//  AppCoordinator.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    enum Scene {
        case puzzle
    }
    
    let session: AppSession
    let navigationController = UINavigationController()
    
    required init(session: AppSession) {
        self.session = session
        navigationController.navigationBar.isTranslucent = false
    }

}

// MARK: - Coordinator Functions
extension AppCoordinator {
    func start() {
        present(.puzzle)
    }
    
    func present(_ scene: Scene) {
        switch scene {
        case .puzzle:
            presentPuzzleScene()
        }
    }
    
}

// MARK: - Controller Factory
private extension AppCoordinator {
    func buildPuzzleController() -> PuzzleViewController {
        let controller = PuzzleViewController()
        // TODO: Inject solvable puzzle
        let manager = PuzzleViewManager(puzzle: Puzzle.mostlyFull)
        controller.manager = manager
        return controller
    }
    
}

// MARK: - Presentation Helpers
private extension AppCoordinator {
    func presentPuzzleScene() {
        navigationController.pushViewController(
            buildPuzzleController(),
            animated: false
        )
    }
}

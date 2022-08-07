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
        case detector
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
        present(.detector)
    }
    
    func present(_ scene: Scene) {
        switch scene {
        case .detector:
            presentDetectorScene()
        case .puzzle:
            presentPuzzleScene()
        }
    }
    
}

// MARK: - Controller Factory
private extension AppCoordinator {
    func buildPuzzleController() -> PuzzleViewController {
        let controller = PuzzleViewController(model: .init(puzzle: Puzzle(values: Puzzle.expert2Values)))
        // TODO: Inject solvable puzzle
        return controller
    }
    
    func buildDetectorController() -> DetectorViewController {
        return DetectorViewController()
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
    
    func presentDetectorScene() {
        navigationController.pushViewController(
            buildDetectorController(),
            animated: false
        )
    }
}

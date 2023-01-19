//
//  AppCoordinator.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Combine
import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    enum Scene {
        case menu
        case puzzle
        case detector
    }
    
    private var cancellables = [AnyCancellable]()
    let navigationController = UINavigationController()
    
    required init() {
        navigationController.navigationBar.isTranslucent = false
    }

}

// MARK: - Coordinator Functions
extension AppCoordinator {
    func start() {
        present(.menu)
    }
    
    func present(_ scene: Scene) {
        switch scene {
        case .menu:
            presentMenuController()
        case .detector:
            presentDetectorScene()
        case .puzzle:
            presentPuzzleScene()
        }
    }
    
}

// MARK: - Controller Factory
private extension AppCoordinator {
    func buildMenuController() -> MenuViewController {
        let model = MenuViewControllerModel()
        model.action.sink { [weak self] action in
            switch action {
            case .didTapScan:
                self?.presentDetectorScene()
            case .didTapSpeedTest:
                self?.presentDetectorScene()
//            case .didTapSettings:
//                print("settings!")
            }
        }
        .store(in: &cancellables)
        
        return MenuViewController(model: model)
    }
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
    func presentMenuController() {
        navigationController.pushViewController(
            buildMenuController(),
            animated: false
        )
    }
    
    func presentPuzzleScene() {
        navigationController.pushViewController(
            buildPuzzleController(),
            animated: true
        )
    }
    
    func presentDetectorScene() {
        navigationController.pushViewController(
            buildDetectorController(),
            animated: true
        )
    }
}

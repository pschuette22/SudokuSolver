//
//  AppCoordinator.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//
import Combine
import Foundation
import UIKit

final class AppCoordinator: NSObject, ParentCoordinator {
    enum Scene {
        case menu
        case puzzle
        case detector(context: ScanCoordinator.Context)
    }
    let identifier = UUID()
    weak var parent: ParentCoordinator?
    let navigationController: NavigationController
    var children = [Coordinator]()
    private var cancellables = [AnyCancellable]()

    required init(navigationController: NavigationController = .init()) {
        self.navigationController = navigationController
        super.init()

        navigationController.navigationBar.isTranslucent = false
        navigationController.register(navigationStackListener: self)
    }

    func start() {
        present(.menu)
    }

    private func present(_ scene: Scene) {
        switch scene {
        case .menu:
            presentMenuController()
        case let .detector(context):
            presentScannerFlow(context: context)
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
                self?.present(.detector(context: .scanInPuzzle))
            case .didTapSpeedTest:
                self?.present(.detector(context: .speedTest))
//            case .didTapDummyPuzzle:
//                self?.present(.puzzle)
//            case .didTapSettings:
//                print("settings!")
            }
        }
        .store(in: &cancellables)

        return MenuViewController(
            coordinatorIdentifier: self.identifier,
            model: model
        )
    }
    func buildPuzzleController() -> PuzzleViewController {
        let controller = PuzzleViewController(
            coordinatorIdentifier: self.identifier,
            model: .init(puzzle: Puzzle(values: Puzzle.expert2Values))
        )
        // TODO: Inject solvable puzzle
        return controller
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

    func presentScannerFlow(context: ScanCoordinator.Context) {
        let scanCoordinator = ScanCoordinator(
            context: context,
            navigationController: navigationController
        )
        children.append(scanCoordinator)
        scanCoordinator.start()
    }
}

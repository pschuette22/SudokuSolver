//
//  ScanCoordinator.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/7/22.
//
import Combine
import Foundation
import UIKit

final class ScanCoordinator: NSObject, Coordinator {
    enum Context {
        case speedTest
        case scanInPuzzle
    }
    enum Scene {
        case scanner
    }

    let identifier = UUID()
    private let context: Context
    var navigationController: NavigationController
    weak var parent: ParentCoordinator?
    private var cancellables = [AnyCancellable]()

    required init(
        context: Context,
        navigationController: NavigationController
    ) {
        self.context = context
        self.navigationController = navigationController

        super.init()

        registerAsNavigationStackListener()
    }

    func start() {
        present(.scanner)
    }

    private func present(_ scene: Scene) {
        switch scene {
        case .scanner:
            presentDetectorScene()
        }
    }
}

// MARK: - Detector Scene
private extension ScanCoordinator {
    func presentDetectorScene() {
        var context: DetectorViewControllerModel.Context
        switch self.context {
        case .scanInPuzzle:
            context = .retrieveValues
        case .speedTest:
            context = .solveInPlace
        }

        let viewModel = DetectorViewControllerModel(context: context)
        viewModel.action.sink { [weak self] action in
            self?.handle(detectorAction: action)
        }
        .store(in: &cancellables)

        navigationController.pushViewController(
            DetectorViewController(
                coordinatorIdentifier: self.identifier,
                model: viewModel
            ),
            animated: true
        )
    }

    private func handle(detectorAction action: DetectorViewControllerModel.Action) {
        switch action {
        case let .didScan(values):
            presentPuzzleScene(values: values)
        case .error:
            // TODO: present an alert
            navigationController.popViewController(animated: true)
        }
    }
}

// MARK: - Puzzle Scene
private extension ScanCoordinator {
    func presentPuzzleScene(values: [[Int?]]) {
        // Convert nil values (errors) to 0 for now
        let mappedValues = values.map {
            $0.map {
                $0 ?? 0
            }
        }
        let viewController = PuzzleViewController(
            coordinatorIdentifier: self.identifier,
            model: .init(puzzle: .init(values: mappedValues))
        )
        var viewControllers = navigationController
            .viewControllers
            .filter { ($0 is DetectorViewController) == false }
        viewControllers.append(viewController)
        navigationController.setViewControllers(viewControllers, animated: true)
    }
}

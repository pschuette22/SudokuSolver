//
//  MenuViewControllerModel.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/6/22.
//

import Combine
import Foundation

class MenuViewControllerModel: ViewModel<MenuViewState> {
    private(set) lazy var action = actionSubject.eraseToAnyPublisher()
    fileprivate let actionSubject = PassthroughSubject<Action, Never>()

    enum Action: Hashable {
        case didTapScan
        case didTapSpeedTest
//        case didTapSettings
    }
    
    override init(initialState state: MenuViewState = .init()) {
        super.init(initialState: state)
    }

    func cellModel(for option: MenuViewState.Option) -> MenuItemCellState {
        return MenuItemCellState(option: option)
    }
}

// MARK: - Tap Handling

extension MenuViewControllerModel {
    func didTapItem(at indexPath: IndexPath) {
        guard
            let option = state.options[safe: indexPath.row]
        else { return }
        
        switch option {
        case .scan:
            actionSubject.send(.didTapScan)
        case .speedTest:
            actionSubject.send(.didTapSpeedTest)
//        case .settings:
//            actionSubject.send(.didTapSettings)
        }
    }
}

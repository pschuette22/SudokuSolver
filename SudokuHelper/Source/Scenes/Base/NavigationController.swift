//
//  NavigationController.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 8/8/22.
//

import Foundation
import UIKit

protocol NavigationStackListener: AnyObject {
    func navigationStackDidChange()
}

class NavigationController: UINavigationController {
    private struct NavigationStackListenerWrapper {
        weak var listener: NavigationStackListener?
    }

    private var navigationStackListeners = [NavigationStackListenerWrapper]()
    
    override var delegate: UINavigationControllerDelegate? {
        didSet {
            assert(delegate.isNil || (delegate as? NavigationController) == self)
        }
    }

    override init(navigationBarClass: AnyClass? = nil, toolbarClass: AnyClass? = nil) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        delegate = self
    }
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        delegate = self
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func register(navigationStackListener: NavigationStackListener) {
        navigationStackListeners.append(.init(listener: navigationStackListener))
    }
}

// MARK: - UINavigationControllerDelegate

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        navigationStackListeners = self.navigationStackListeners.filter {
            $0.listener.isNotNil
        }
        navigationStackListeners.forEach {
            $0.listener?.navigationStackDidChange()
        }
    }
}

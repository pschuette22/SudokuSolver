//
//  ViewController.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/20/21.
//

import UIKit
import Combine

class ViewController<State: ViewState, Model: ViewModel<State>>: UIViewController {
    private(set) var model: Model
    private var stateSubscriptions = Set<AnyCancellable>()
    
    required init(model: Model) {
        self.model = model

        super.init(nibName: nil, bundle: nil)

        stateSubscriptions.insert(
            model.$state.sink(
                receiveValue: { [weak self] state in
                    self?.render(state)
                }
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("Decoding not supported")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSubviews()
        render(model.state)
    }
    
    func setupSubviews() {
        Logger.log(.warning, message: "setupSubviews not implemented for \(String(describing: type(of: self)))")
    }
    
    func render(_ state: State) {
        Logger.log(.error, message: "render(_state:) not implemented for \(String(describing: type(of: self)))")
    }
}

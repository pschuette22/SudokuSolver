import UIKit
import Combine

protocol CoordinatedViewController: UIViewController {
    var coordinatorIdentifier: UUID { get }
}

class ViewController<State: ViewState, Model: ViewModel<State>>: UIViewController, CoordinatedViewController {
    private(set) var model: Model
    private var stateSubscription: AnyCancellable?
    let coordinatorIdentifier: UUID

    required init(
        coordinatorIdentifier: UUID,
        model: Model
    ) {
        self.coordinatorIdentifier = coordinatorIdentifier
        self.model = model

        super.init(nibName: nil, bundle: nil)
        
        setupSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Decoding not supported")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        stateSubscription = model.$state
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] state in
                self?.render(state)
            }
        render(model.state)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stateSubscription?.cancel()
        stateSubscription = nil
    }
    
    func setupSubviews() {
        Logger.log(.warning, message: "setupSubviews not implemented for \(String(describing: type(of: self)))")
    }
    
    func render(_ state: State) {
        Logger.log(.error, message: "render(_state:) not implemented for \(String(describing: type(of: self)))")
    }
}

import RealmSwift
import Foundation

class Store {
    
    init(sideEffect: @escaping SideEffect) {
        self.sideEffect = sideEffect
    }
    
    let sideEffect: SideEffect
    
    // App identity
    lazy fileprivate(set) var state: State = State.initialState
    lazy fileprivate(set) var dataSource: DataSource = DataSource(store: self)
    
    fileprivate var timer: Timer?
    
    // Returns a function which can be used to dispatch actions
    var dispatch: Dispatch {
        get {
            return dispatcher(applicationReducer, storeChanged: { [weak self] state, action in
                self?.state = state
                self?.dataSource = DataSource(store: self)
                self?.sideEffect(state, action)
                })({
                    return self.state
                })
        }
    }
    
    func startTimer(_ every: TimeInterval, do block: @escaping () -> Void) {
        let executor = BlockExecutor(block: block)
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: every,
                                     target: executor,
                                     selector: #selector(executor.execute),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

class BlockExecutor {
    init(block: @escaping () -> Void) {
        self.block = block
    }
    
    let block: () -> Void
    @objc func execute() {
        block()
    }
}

extension DataSource {
    convenience init(store: Store?) {
        guard let store = store else {
            self.init(viewModels: [], dispatch: { _ in })
            return
        }
        let tasks = Array(store.state.tasks.values)
        let viewModels = tasks.map { task -> TaskCellViewModel in
            return TaskCellViewModel(task: task, store: store)
        }
        self.init(viewModels: viewModels, dispatch: store.dispatch)
    }
}

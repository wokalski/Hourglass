import RealmSwift
import Foundation

class Store {
    
    init(realm: Realm, sideEffect: SideEffect) {
        self.realm = realm
        self.sideEffect = sideEffect
    }
    
    let sideEffect: SideEffect
    let realm: Realm
    
    // App identity
    lazy private(set) var state: State = State(runningTask: nil,
                                               tasks: tasks(in: self.realm),
                                               selected: nil)
    lazy private(set) var dataSource: DataSource = DataSource(store: self)
    
    private var timer: Timer?
    
    // Returns a function which can be used to dispatch actions
    var dispatch: Dispatch {
        get {
            return dispatcher(reducer: applicationReducer, storeChanged: { [weak self] state, action in
                self?.state = state
                self?.dataSource = DataSource(store: self)
                self?.sideEffect(state: state, action: action)
            })(state: state)
        }
    }
    
    func startTimer(every: TimeInterval, do block: () -> Void) {
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
    
    init(block: () -> Void) {
        self.block = block
    }
    
    let block: () -> Void
    @objc func execute() {
        block()
    }
}

func tasks(in realm: Realm) -> TaskIndex {
    let results = realm.allObjects(ofType: Task.self).sorted(onProperty: "id", ascending: true)
    return dictionary(from: results)
}


extension DataSource {
    convenience init(store: Store?) {
        guard let store = store else {
            self.init(viewModels: [], dispatch: { _ in })
            return
        }
        let state = store.state
        let tasks = Array(state.tasks.values)
        let viewModels = tasks.map { task -> TaskCellViewModel in
            let selected = store.state.selectedTask?.id == task.id
            let running = task.id == state.runningTask?.id
            return TaskCellViewModel(task: task,
                                     selected: selected,
                                     onClick: { [weak store] in
                                        if running {
                                            store?.dispatch(action: .StopTask(task: task))
                                        } else {
                                            store?.dispatch(action: .StartTask(task: task))
                                        }
                }, running: running)
        }
        self.init(viewModels: viewModels, dispatch: store.dispatch)
    }
}

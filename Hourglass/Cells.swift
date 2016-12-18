import AppKit

enum CellType {
    case task(task: TaskCellViewModel)
    case newTask(action: NewTaskAction)
    
    func cellClass() -> NSCollectionViewItem.Type {
        switch self {
        case .task:
            return TaskCell.self
        case .newTask:
            return NewTaskCell.self
        }
    }
    
    func configureCell(_ cell: NSCollectionViewItem) {
        switch self {
        case let .task(task):
            if let cell = cell as? TaskCell {
                cell.viewModel = task
            }
        case let .newTask(action):
            if let cell = cell as? NewTaskCell {
                cell.onReturn = action
            }
        }
    }
}

func configureReusableCellsOf(_ collectionView: NSCollectionView) {
    let bundle = Bundle(for: NewTaskCell.self)
    let newTask = NSNib(nibNamed: "NewTask", bundle: bundle)
    let task = NSNib(nibNamed: "Task", bundle: bundle)
    let newTaskIdentifier = String(describing: NewTaskCell.self)
    let taskIdentifier = String(describing: TaskCell.self)
    
    collectionView.register(newTask, forItemWithIdentifier: newTaskIdentifier)
    collectionView.register(task, forItemWithIdentifier: taskIdentifier)
}

func cell<T>(_ type: T.Type, in collectionView: NSCollectionView, at indexPath: IndexPath) -> T {
    let identifier = String(describing: type)
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    guard item is T else {
        fatalError()
    }
    return item as! T
}

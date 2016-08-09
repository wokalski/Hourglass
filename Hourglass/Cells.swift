import AppKit
import RealmSwift
import ReactiveCocoa.Swift

enum CellType {
    case Task(task: TaskCellViewModel)
    case NewTask(action: NewTaskAction)
    
    func cellClass() -> NSCollectionViewItem.Type {
        switch self {
        case .Task:
            return TaskCell.self
        case .NewTask:
            return NewTaskCell.self
        }
    }
    
    func configureCell(cell: NSCollectionViewItem) {
        switch self {
        case let .Task(task):
            if let cell = cell as? TaskCell {
                cell.viewModel = task
            }
        case let .NewTask(action):
            if let cell = cell as? NewTaskCell {
                cell.onReturn = action
            }
        }
    }
}

func configureReusableCellsOf(collectionView: NSCollectionView) {
    let bundle = Bundle(for: NewTaskCell.self)
    let newTask = NSNib(nibNamed: "NewTask", bundle: bundle)
    let task = NSNib(nibNamed: "Task", bundle: bundle)
    let newTaskIdentifier = String(NewTaskCell.self)
    let taskIdentifier = String(TaskCell.self)
    
    collectionView.register(newTask, forItemWithIdentifier: newTaskIdentifier)
    collectionView.register(task, forItemWithIdentifier: taskIdentifier)
}

func cell<T>(factory: T.Type, in collectionView: NSCollectionView, at indexPath: IndexPath) -> T {
    let identifier = String(factory)
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    guard item is T else {
        fatalError()
    }
    return item as! T
}

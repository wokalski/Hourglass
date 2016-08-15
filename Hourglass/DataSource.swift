import AppKit
import RealmSwift
import ReactiveCocoa
import Result

class DataSource: NSObject, NSCollectionViewDataSource {
    
    init(viewModels: [TaskCellViewModel],
         dispatch: (action: Action) -> Void) {
        self.viewModels = viewModels
        self.dispatch = dispatch
        super.init()
    }
    
    let dispatch: (action: Action) -> Void
    let viewModels: [TaskCellViewModel]
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModels.count
        case 1:
            return 1
        default:
            fatalError()
        }
    }
    
    func cellType(at indexPath: IndexPath) -> CellType {
        switch indexPath.section {
        case 0:
            return .Task(task: viewModels[indexPath.item])
        case 1:
            return .NewTask(action: { [weak self] (name, time) in
                self?.dispatch(action: newTaskAction(name, totalTime: time))
            })
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cellType = self.cellType(at: indexPath)
        let initiatedCell = cell(type: cellType.cellClass(), in: collectionView, at: indexPath)
        cellType.configureCell(cell: initiatedCell)
        return initiatedCell
    }
}

func newTaskAction(_ name: String, totalTime: HGDuration?) -> Action {
    if let totalTime = totalTime {
        let task = Task()
        task.name = name
        task.totalTime = totalTime
        return .NewTask(task: task)
    }
    return .NewTask(task: nil)
}

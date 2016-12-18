import AppKit
import RealmSwift

class DataSource: NSObject, NSCollectionViewDataSource {
    
    init(viewModels: [TaskCellViewModel],
         dispatch: @escaping (Action) -> Void) {
        self.viewModels = viewModels
        self.dispatch = dispatch
        super.init()
    }
    
    let dispatch: (Action) -> Void
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
            return .task(task: viewModels[indexPath.item])
        case 1:
            return .newTask(action: { [weak self] (name, time) in
                self?.dispatch(newTaskAction(name, totalTime: time))
            })
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cellType = self.cellType(at: indexPath)
        let initiatedCell = cell(cellType.cellClass(), in: collectionView, at: indexPath)
        cellType.configureCell(initiatedCell)
        return initiatedCell
    }
}

func newTaskAction(_ name: String, totalTime: HGDuration?) -> Action {
    if let totalTime = totalTime {
        let task = Task()
        task.name = name
        task.totalTime = totalTime
        return .newTask(task: task)
    }
    return .newTask(task: nil)
}

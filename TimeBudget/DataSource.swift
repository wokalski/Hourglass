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
    var sections: Sections {
        get {
            return Sections(tasks: viewModels, newTaskAction: { name, time in
                self.dispatch(action: newTaskAction(name, totalTime: time))
            })
        }
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return Sections.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.numberOfItems(section: section)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cellType = sections.cellType(at: indexPath)
        let initiatedCell = cell(factory: cellType.cellClass(), in: collectionView, at: indexPath)
        cellType.configureCell(cell: initiatedCell)
        return initiatedCell
    }
}

struct Sections {
    let tasks: [TaskCellViewModel]
    let newTaskAction: NewTaskAction
    static let count = 2
}

extension Sections {
    
    func numberOfItems(section: Int) -> Int {
        switch section {
        case 0:
            return tasks.count
        case 1:
            return 1
        default:
            fatalError()
        }
    }
    
    func cellType(at indexPath: IndexPath) -> CellType {
        switch indexPath.section {
        case 0:
            return .Task(task: tasks[indexPath.item])
        case 1:
            return .NewTask(action: newTaskAction)
        default:
            fatalError()
        }
    }
}

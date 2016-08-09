import Foundation
import RealmSwift
import AppKit

func sideEffects(app: ViewController) -> SideEffect {
    return { state, action in
        app.collectionView.dataSource = app.store.dataSource
        
        switch action {
        case let .NewTask(task):
            guard let task = task else {
                NSBeep()
                return
            }
            try! app.store.realm.write {
                app.store.realm.add(task)
            }
            app.collectionView.reloadData()
        case let .RemoveTask(task):
            if state.runningTask == nil {
                app.store.stopTimer()
            }
            try! app.store.realm.write {
                app.store.realm.delete(task)
            }
        case let .StartTask(task):
            app.store.startTimer(every: 1, do: {
                app.store.dispatch(action:
                    .TaskUpdate(task:
                        TaskUpdate(task: task)
                            .set(timeElapsed: task.timeElapsed + 1
                        )
                    )
                )
            })
        case .StopTask:
            app.store.stopTimer()
        case .TaskUpdate:
            app.collectionView.reloadData()
        case let .Select(indexPath):
            guard let indexPath = indexPath else {
                app.collectionView.deselectAll(nil)
                return
            }
            app.collectionView.reloadItems(at: Set([indexPath]))
            break
        }
    }
}

func createTask(name: String, time: TimeInterval) -> Task {
    let task = Task()
    task.name = name
    task.totalTime = time
    return task
}

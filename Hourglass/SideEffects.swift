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
        case .StartTask: // Running task might actually be nil - if the task was completed it cannot be started
            if let runningTask = state.runningTask {
                app.store.startTimer(every: 1, do: {
                    app.store.dispatch(action:
                        .TaskUpdate(task:
                            TaskUpdate(task: runningTask)
                                .set(timeElapsed: runningTask.timeElapsed + 1
                            )
                        )
                    )
                })
            }
        case let .StopTask(task):
            if task.timeElapsed == task.totalTime {
                let notification = NSUserNotification()
                notification.title = "Completed a task"
                notification.subtitle = task.name
                NSUserNotificationCenter.default.deliver(notification)
            }
            app.store.stopTimer()
        case .TaskUpdate:
            if let runningTask = state.runningTask {
                if runningTask.timeElapsed >= runningTask.totalTime {
                    app.store.dispatch(action: .StopTask(task: runningTask))
                }
            }
            app.collectionView.reloadData()
        case .Select:
            guard let indexPath = state.selected else {
                app.collectionView.deselectAll(nil)
                return
            }
            app.collectionView.reloadItems(at: Set([indexPath]))
            break
        }
    }
}

func createTask(name: String, time: IntMax) -> Task {
    let task = Task()
    task.name = name
    task.totalTime = time
    return task
}

import Foundation
import RealmSwift
import AppKit
import EventKit

func sideEffects(app: ViewController) -> SideEffect {
    return { state, action in
        app.collectionView.dataSource = app.store.dataSource
        let realm = app.store.realm
        
        switch action {
        case let .NewTask(task):
            guard let task = task else {
                NSBeep()
                return
            }
            try! realm.write {
                realm.add(task)
            }
            app.collectionView.reloadData()
        case let .RemoveTask(task):
            if state.currentSession == nil {
                app.store.stopTimer()
            }
            try! realm.write {
                realm.delete(task)
            }
        case .SessionUpdate(let sessionAction):
            workSessionUpdate(app: app, state: state, action: sessionAction)
        case .TaskUpdate:
            guard let session = state.currentSession,
                  let runningTask = session.task else {
                    return
            }
            
            if runningTask.timeElapsed >= runningTask.totalTime {
                app.store.dispatch(action: .SessionUpdate(action: .terminate(session: session)))
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

func workSessionUpdate(
    app: ViewController,
    state: State,
    action: WorkSessionAction) {
    
    let realm = app.store.realm
    
    switch action {
    case .start:
        guard let session = state.currentSession,
            let runningTask = session.task else {
                return
        }
        
        try! realm.write {
            realm.add(session)
        }
        
        app.store.startTimer(every: 1, do: {
            app.store.dispatch(action:
                .TaskUpdate(task:
                    TaskUpdate(task: runningTask)
                        .set(timeElapsed: runningTask.timeElapsed + 1
                    )
                )
            )
        })
    case .terminate(let session):
        app.store.stopTimer()
        
        guard let task = session.task else {
            return
        }
        
        try! realm.write {
            realm.delete(session)
        }
        
        if task.timeElapsed == task.totalTime {
            let notification = NSUserNotification()
            notification.title = "Completed a task"
            notification.subtitle = task.name
            NSUserNotificationCenter.default.deliver(notification)
        }
        
        addEvent(startTime: session.startTime, task: task)
    }
}

func addEvent(startTime: IntMax, task: Task) {
    // TODO: Implement
}

func createTask(name: String, time: IntMax) -> Task {
    let task = Task()
    task.name = name
    task.totalTime = time
    return task
}

import Foundation
import RealmSwift
import AppKit
import EventKit

func sideEffects(app: ViewController) -> SideEffect {
    return { [weak app] state, action in
        guard let app = app else {
            return
        }
        
        app.collectionView?.dataSource = app.store.dataSource
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
            app.collectionView?.reloadData()
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
            guard let session = state.currentSession else {
                    return
            }
            
            let task = session.task
            
            if task.timeElapsed >= task.totalTime {
                app.store.dispatch(action: .SessionUpdate(action: .terminate(session: session)))
            }
            app.collectionView?.reloadData()
        case .Select:
            guard let indexPath = state.selected else {
                app.collectionView?.deselectAll(nil)
                return
            }
            app.collectionView?.reloadItems(at: Set([indexPath]))
            break
        case .Calendar:
            break
        case .Quit:
            if let session = state.currentSession {
                app.store.dispatch(action: .SessionUpdate(action: .terminate(session: session)))
            }
        }
    }
}

func workSessionUpdate(
    app: ViewController,
    state: State,
    action: WorkSessionAction) {
        
    switch action {
    case .start:
        guard let session = state.currentSession else {
                return
        }
        
        app.store.startTimer(every: 1, do: {
            app.store.dispatch(action:
                .TaskUpdate(task:
                    TaskUpdate(task: session.task)
                        .set(timeElapsed: session.task.timeElapsed + 1
                    )
                )
            )
        })
    case .terminate(let session):
        app.store.stopTimer()
        let task = session.task
        
        if task.timeElapsed == task.totalTime {
            let notification = NSUserNotification()
            notification.title = "Completed a task"
            notification.subtitle = task.name
            NSUserNotificationCenter.default.deliver(notification)
        }
        
        guard let logTarget = state.logTarget else {
            return
        }
        
        let event = EKEvent(eventStore: logTarget.eventStore)
        let now = Date()
        event.title = task.name
        event.endDate = now
        event.startDate = now.addingTimeInterval(-(Double(IntMax.subtractWithOverflow(task.timeElapsed, session.startTime).0)))
        event.calendar = logTarget.calendar
        do {
            try logTarget.eventStore.save(event, span: .thisEvent, commit: true)
        } catch {
            print("Added event from another event store")
            fatalError()
        }
    }
}

func createTask(name: String, time: IntMax) -> Task {
    let task = Task()
    task.name = name
    task.totalTime = time
    return task
}

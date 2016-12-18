import Foundation
import RealmSwift
import AppKit
import EventKit

func sideEffects(_ app: ViewController) -> SideEffect {
    return { [weak app] state, action in
        guard let app = app else {
            return
        }
        
        app.collectionView?.dataSource = app.store.dataSource
        let realm = app.realm
        let dispatch = app.store.dispatch
        
        switch action {
        case let .newTask(task):
            guard let task = task else {
                NSBeep()
                return
            }
            
            if task.realm == nil {
                try! realm.write {
                    realm.add(task)
                }
            }
            
            app.collectionView?.reloadData()
        case let .removeTask(task):
            if state.currentSession == nil {
                app.store.stopTimer()
            }
            try! realm.write {
                realm.delete(task)
            }
        case .taskUpdate:
            guard let session = state.currentSession else {
                    return
            }
            
            let task = session.task
            
            if task.timeElapsed >= task.totalTime {
                dispatch(.sessionUpdate(action: .terminate(session: session)))
            }
            app.collectionView?.reloadData()
        case .select:
            guard let indexPath = state.selected else {
                app.collectionView?.deselectAll(nil)
                return
            }
            app.collectionView?.reloadItems(at: Set([indexPath]))
        case .quit:
            if let session = state.currentSession {
                dispatch(.sessionUpdate(action: .terminate(session: session)))
            }
        case .initialize:
            let newTaskActions: [Action] = realm.objects(Task.self)
                .sorted(byProperty: "timeElapsed", ascending: false)
                .map { task in
                    .newTask(task: task)
            }
            newTaskActions.forEach { action in
                dispatch(action)
            }
            
            dispatch(.calendar(action: .initDefault))
        case let .calendar(action):
            handleCalendarAction(dispatch, state, action)
        case .sessionUpdate(let sessionAction):
            workSessionUpdate(app, state: state, action: sessionAction)
        }
    }
}

func createTask(_ name: String, time: HGDuration) -> Task {
    let task = Task()
    task.name = name
    task.totalTime = time
    return task
}

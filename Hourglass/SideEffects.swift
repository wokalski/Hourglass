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
        let realm = app.realm
        let dispatch = app.store.dispatch
        
        switch action {
        case let .NewTask(task):
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
        case let .RemoveTask(task):
            if state.currentSession == nil {
                app.store.stopTimer()
            }
            try! realm.write {
                realm.delete(task)
            }
        case .TaskUpdate:
            guard let session = state.currentSession else {
                    return
            }
            
            let task = session.task
            
            if task.timeElapsed >= task.totalTime {
                dispatch(action: .SessionUpdate(action: .terminate(session: session)))
            }
            app.collectionView?.reloadData()
        case .Select:
            guard let indexPath = state.selected else {
                app.collectionView?.deselectAll(nil)
                return
            }
            app.collectionView?.reloadItems(at: Set([indexPath]))
        case .Quit:
            if let session = state.currentSession {
                dispatch(action: .SessionUpdate(action: .terminate(session: session)))
            }
        case .Init:
            let newTaskActions: [Action] = realm.allObjects(ofType: Task.self)
                .sorted(onProperty: "timeElapsed", ascending: false)
                .map { task in
                    .NewTask(task: task)
            }
            newTaskActions.forEach { action in
                dispatch(action: action)
            }
            
            dispatch(action: .Calendar(action: .initDefault))
        case let .Calendar(action):
            handleCalendarAction(dispatch, state, action)
        case .SessionUpdate(let sessionAction):
            workSessionUpdate(app: app, state: state, action: sessionAction)
        }
    }
}

func createTask(name: String, time: HGDuration) -> Task {
    let task = Task()
    task.name = name
    task.totalTime = time
    return task
}

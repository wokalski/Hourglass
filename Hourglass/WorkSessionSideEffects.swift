import Foundation

func workSessionUpdate(
    _ app: ViewController,
    state: State,
    action: WorkSessionAction) {
    
    let dispatch = app.store.dispatch
    
    switch action {
    case .start:
        guard let session = state.currentSession else {
            return
        }
        
        app.store.startTimer(1, do: {
            dispatch(.taskUpdate(task:
                    TaskUpdate(task: session.task)
                        .set(session.task.timeElapsed + 1
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
        
        dispatch(.calendar(action: .logTask(task: task, startTime: session.startTime)))
    }
}

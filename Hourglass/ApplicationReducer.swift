
func applicationReducer(state: State, action: Action) -> State {
    switch action {
    case let .NewTask(task):
        if let task = task {
            return state.set(tasks:
                state.tasks.set(task.id, task)
            )
        }
        return state
    case .RemoveTask(let task):
        let removingSelected = task.id == state.selectedTask?.id
        let selected = removingSelected ? nil : state.selected
        let removingRunning = state.currentSession?.task.id == task.id
        let session = removingRunning ? nil : state.currentSession
        return State(currentSession: session,
                     tasks: state.tasks.deleting(task.id),
                     selected: selected,
                     logTarget: state.logTarget)
    case .SessionUpdate(let action):
        return workSessionReducer(state: state, action: action)
    case let .TaskUpdate(update):
        let task = state.tasks[update.id]
        if let task = task {
            // Side effects here - not ideal
            var updatedTask = task
            try? task.realm?.write {
                updatedTask = task.apply(update)
            }
            return state.set(tasks: state.tasks.set(updatedTask.id, updatedTask))
        } else {
            return state
        }
    case .Select(let indexPath):
        guard let indexPath = indexPath else {
            return state.set(selected: nil)
        }
        if indexPath == state.selected {
            return state.set(selected: nil)
        }
        return state.set(selected: indexPath)
    case .Calendar(let action):
        return calendarReducer(state: state, action: action)
    case .Quit:
        return state
    }
}

func workSessionReducer(state: State, action: WorkSessionAction) -> State {
    switch action {
    case .start(let task):
        if task.totalTime > task.timeElapsed {
            let session = Session(task: task, startTime: task.timeElapsed)
            return state.set(currentSession: session)
        }
        return state

    case .terminate:
        return state.set(currentSession: nil)
    }
}

func calendarReducer(state: State, action: CalendarAction) -> State {
    switch action {
    case .chooseDefault(let calendar):
        return state.set(logTarget: calendar)
    }
}


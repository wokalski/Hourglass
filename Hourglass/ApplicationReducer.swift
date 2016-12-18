
func applicationReducer(_ state: State, action: Action) -> State {
    switch action {
    case let .newTask(task):
        if let task = task {
            return state.set(tasks:
                state.tasks.set(task.id, task)
            )
        }
        return state
    case .removeTask(let task):
        let removingSelected = task.id == state.selectedTask?.id
        let selected = removingSelected ? nil : state.selected
        let removingRunning = state.currentSession?.task.id == task.id
        let session = removingRunning ? nil : state.currentSession
        return State(currentSession: session,
                     tasks: state.tasks.deleting(task.id),
                     selected: selected,
                     logTarget: state.logTarget)
    case .sessionUpdate(let action):
        return workSessionReducer(state, action: action)
    case let .taskUpdate(update):
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
    case .select(let indexPath):
        guard let indexPath = indexPath else {
            return state.set(selected: nil)
        }
        if indexPath == state.selected {
            return state.set(selected: nil)
        }
        return state.set(selected: indexPath)
    case .calendar(let action):
        return calendarReducer(state, action: action)
    case .quit:
        return state
    case .initialize:
        return state
    }
}

func workSessionReducer(_ state: State, action: WorkSessionAction) -> State {
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

func calendarReducer(_ state: State, action: CalendarAction) -> State {
    switch action {
    case .chooseDefault(let calendar):
        return state.set(logTarget: calendar)
    case .logTask, .initDefault:
        return state
    }
}


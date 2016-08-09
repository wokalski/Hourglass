
func applicationReducer(state: State, action: Action) -> State {
    switch action {
    case let .NewTask(task):
        if let task = task {
            return state.set(tasks:
                state.tasks.set(task.id, task)
            )
        }
        return state
    case let .RemoveTask(task):
        let removingSelected = task.id == state.selectedTask?.id
        let selected = removingSelected ? nil : state.selected
        let removingRunning = state.runningTask?.id == task.id
        let running = removingRunning ? nil : state.runningTask
        return State(runningTask: running,
                     tasks: state.tasks.deleting(task.id),
                     selected: selected)
    case let .StartTask(task):
        if task.totalTime > task.timeElapsed {
            return state.set(runningTask: task)
        }
        return state
    case .StopTask:
        return state.set(runningTask: nil)
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
    case let .Select(indexPath):
        guard let indexPath = indexPath else {
            return state.set(selected: nil)
        }
        if indexPath == state.selected {
            return state.set(selected: nil)
        }
        return state.set(selected: indexPath)
    }
}

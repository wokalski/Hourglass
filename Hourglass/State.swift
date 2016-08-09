import Foundation

typealias TaskIndex = [TaskID : Task]

struct State {
    let runningTask: Task?
    let tasks: TaskIndex
    let selected: IndexPath?
    
    static let initialState = State(runningTask: nil,
                                    tasks: [:],
                                    selected: nil)
}

extension State {
    func set(visibleCells: [TaskID: IndexPath]) -> State {
        return State(
            runningTask: runningTask,
            tasks: tasks,
            selected: selected)
    }
    func set(runningTask: Task?) -> State {
        return State(
            runningTask: runningTask,
            tasks: tasks,
            selected: selected)
    }
    func set(tasks: [Int : Task]) -> State {
        return State(
            runningTask: runningTask,
            tasks: tasks,
            selected: selected)
    }
    func set(selected: IndexPath?) -> State {
        return State(
            runningTask: runningTask,
            tasks: tasks,
            selected: selected)
    }
}

extension State {
    var selectedTask: Task? {
        get {
            guard let indexPath = selected else {
                return nil
            }
            return taskAtIndexPath(indexPath: indexPath)
        }
    }
    
    func taskAtIndexPath(indexPath: IndexPath) -> Task? {
        if indexPath.section == 0 {
            return Array(tasks.values)[indexPath.item]
        }
        return nil
    }
}
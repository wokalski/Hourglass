import Foundation
import EventKit

typealias TaskIndex = [TaskID : Task]

struct EventLogTarget {
    let calendar: EKCalendar
    let eventStore: EKEventStore
}


struct State {
    let currentSession: Session?
    let tasks: TaskIndex
    let selected: IndexPath?
    let logTarget: EventLogTarget?
}

extension State {
    func set(visibleCells: [TaskID: IndexPath]) -> State {
        return State(
            currentSession: currentSession,
            tasks: tasks,
            selected: selected,
            logTarget: logTarget)
    }
    func set(currentSession: Session?) -> State {
        return State(
            currentSession: currentSession,
            tasks: tasks,
            selected: selected,
            logTarget: logTarget)
    }
    func set(tasks: [Int : Task]) -> State {
        return State(
            currentSession: currentSession,
            tasks: tasks,
            selected: selected,
            logTarget: logTarget)
    }
    func set(selected: IndexPath?) -> State {
        return State(
            currentSession: currentSession,
            tasks: tasks,
            selected: selected,
            logTarget: logTarget)
    }
    func set(logTarget: EventLogTarget?) -> State {
        return State(
            currentSession: currentSession,
            tasks: tasks,
            selected: selected,
            logTarget: logTarget)
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

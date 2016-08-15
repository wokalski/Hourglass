import Foundation
import RealmSwift
import AppKit
import EventKit

enum Action {
    case NewTask(task: Task?)
    case RemoveTask(task: Task)
    case TaskUpdate(task: TaskProtocol)
    case SessionUpdate(action: WorkSessionAction)
    case Calendar(action: CalendarAction)
    case Select(indexPath: IndexPath?)
    case Quit
}

enum WorkSessionAction {
    case start(task: Task)
    case terminate(session: Session)
}

enum CalendarAction {
    case chooseDefault(logTarget: EventLogTarget?)
}

func newTaskAction(_ name: String, totalTime: IntMax?) -> Action {
    if let totalTime = totalTime {
        let task = Task()
        task.name = name
        task.totalTime = totalTime
        return .NewTask(task: task)
    }
    return .NewTask(task: nil)
}

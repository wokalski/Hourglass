import Foundation
import RealmSwift
import AppKit
import EventKit

typealias HGDuration = IntMax

enum Action {
    case newTask(task: Task?)
    case removeTask(task: Task)
    case taskUpdate(task: TaskProtocol)
    case sessionUpdate(action: WorkSessionAction)
    case calendar(action: CalendarAction)
    case select(indexPath: IndexPath?)
    case initialize
    case quit
}

enum WorkSessionAction {
    case start(task: Task)
    case terminate(session: Session)
}

enum CalendarAction {
    case initDefault
    case chooseDefault(logTarget: EventLogTarget?)
    case logTask(task: Task, startTime: HGDuration)
}

enum LifeCycleAction {
    case initialize
    case quit
}

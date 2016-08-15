import Foundation
import RealmSwift
import AppKit
import EventKit

typealias HGDuration = IntMax

enum Action {
    case NewTask(task: Task?)
    case RemoveTask(task: Task)
    case TaskUpdate(task: TaskProtocol)
    case SessionUpdate(action: WorkSessionAction)
    case Calendar(action: CalendarAction)
    case Select(indexPath: IndexPath?)
    case Init
    case Quit
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
    case Init
    case Quit
}

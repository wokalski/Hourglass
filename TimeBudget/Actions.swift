import Foundation
import RealmSwift
import AppKit

enum Action {
    case NewTask(task: Task?)
    case RemoveTask(task: Task)
    case StartTask(task: Task)
    case StopTask(task: Task)
    case TaskUpdate(task: TaskProtocol)
    case Select(indexPath: IndexPath?)
}

func newTaskAction(_ name: String, totalTime: TimeInterval?) -> Action {
    if let totalTime = totalTime {
        let task = Task()
        task.name = name
        task.totalTime = totalTime
        return .NewTask(task: task)
    }
    return .NewTask(task: nil)
}

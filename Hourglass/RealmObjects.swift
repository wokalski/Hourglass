import Foundation
import RealmSwift

typealias TaskID = Int

class Task: Object {
    dynamic var timeElapsed: IntMax = 0
    dynamic var totalTime: IntMax = 0
    dynamic var name = ""
    dynamic var id: TaskID = Int(NSDate.timeIntervalSinceReferenceDate)
    
    func primaryKey() -> String? {
        return "id"
    }
}

struct Session {
    let task: Task
    let startTime: IntMax
}

protocol TaskProtocol {
    var id: TaskID { get }
    var timeElapsed: IntMax { get }
    var totalTime: IntMax { get }
    var name: String { get }
}

extension Task {
    func apply(_ update: TaskProtocol) -> Task {
        totalTime = update.totalTime
        name = update.name
        timeElapsed = update.timeElapsed
        return self
    }
}

struct TaskUpdate: TaskProtocol {
    let id: TaskID
    let timeElapsed: IntMax
    let totalTime: IntMax
    let name: String
}

extension TaskUpdate {
    init(task: Task) {
        self.id = task.id
        self.timeElapsed = task.timeElapsed
        self.totalTime = task.totalTime
        self.name = task.name
    }
    
    func set(timeElapsed: IntMax) -> TaskUpdate {
        return TaskUpdate(id: id,
                          timeElapsed: timeElapsed,
                          totalTime: totalTime,
                          name: name)
    }
}

func dictionary(from results: Results<Task>) -> [TaskID : Task] {
    var dict = [TaskID : Task]()
    for task in results {
        dict[task.id] = task
    }
    return dict
}

import AppKit

struct TaskCellViewModel {
    let backgroundColor: CGColor
    let textColor: NSColor
    let progress: Double
    let timeText: String
    let name: String
    let onClick: () -> Void
    let buttonImage: NSImage?
    let alternateImage: NSImage?
}

extension TaskCellViewModel {
    
    init(task: Task,
         store: Store) {
        let state = store.state
        let selected = state.selectedTask?.id == task.id
        let running = task.id == state.currentSession?.task.id
        self.init(task: task,
                  selected: selected,
                  onClick: { [weak store] in
                    store?.dispatch(action: .SessionUpdate(action: handler(task: task, state: state)))
            }, running: running)
    }

    private init(task: Task,
         selected: Bool = false,
         onClick: () -> Void,
         running: Bool) {
        let white = NSColor.white
        let black = NSColor.black
        
        let complete = task.totalTime == task.timeElapsed
        
        backgroundColor = backgroundForState(selected: selected)
        textColor = selected ? white : black
        progress = Double(task.timeElapsed) / Double(task.totalTime)
        timeText = "\(task.timeElapsed.timeString())/\(task.totalTime.timeString())"
        name = task.name
        self.onClick = onClick

        if complete {
            buttonImage = nil
            alternateImage = nil
        } else {
            buttonImage = running ? #imageLiteral(resourceName: "PauseButton") : #imageLiteral(resourceName: "PlayButton")
            alternateImage = running ? #imageLiteral(resourceName: "PauseButtonAlternate") : #imageLiteral(resourceName: "PlayButtonAlternate")
        }
    }
}

private func backgroundForState(selected: Bool) -> CGColor {
    let clear = NSColor.clear.cgColor
    let blue = NSColor.blue.cgColor
    return selected ? blue : clear
}

func handler(task: Task, state: State) -> WorkSessionAction {
    if let session = state.currentSession,
        session.task.id == task.id {
        return .terminate(session: session)
    } else {
        return .start(task: task)
    }
}

extension HGDuration {
    func timeString() -> String {
        let interval = self
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

import AppKit

struct TaskCellViewModel {
    let backgroundColor: CGColor
    let textColor: NSColor
    let progress: Double
    let timeText: String
    let name: String
    let onClick: () -> Void
    let buttonImage: NSImage
    let alternateImage: NSImage
}

extension TaskCellViewModel {
    init(task: Task,
         selected: Bool = false,
         onClick: () -> Void,
         running: Bool) {
        let white = NSColor.white
        let black = NSColor.black
        
        backgroundColor = backgroundForState(selected: selected)
        textColor = selected ? white : black
        progress = task.timeElapsed/task.totalTime
        timeText = "\(task.timeElapsed.timeString())/\(task.totalTime.timeString())"
        name = task.name
        buttonImage = running ? #imageLiteral(resourceName: "PauseButton") : #imageLiteral(resourceName: "PlayButton")
        alternateImage = running ? #imageLiteral(resourceName: "PauseButtonAlternate") : #imageLiteral(resourceName: "PlayButtonAlternate")
        self.onClick = onClick
    }
}

private func backgroundForState(selected: Bool) -> CGColor {
    let clear = NSColor.clear.cgColor
    let blue = NSColor.blue.cgColor
    return selected ? blue : clear
}

extension TimeInterval {
    func timeString() -> String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

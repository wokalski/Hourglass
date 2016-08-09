import AppKit

typealias NewTaskAction = (name: String, time: TimeInterval?) -> Void

class NewTaskCell: NSCollectionViewItem {
    
    @IBOutlet private var taskNameLabel: NSTextField!
    @IBOutlet private var timeLabel: NSTextField!
    var onReturn: NewTaskAction = {_,_ in  }
    
    @IBAction func add(_ sender: NSTextField) {
        onReturn(name: taskNameLabel.stringValue, time: timeInterval(from: timeLabel.stringValue))
        taskNameLabel.stringValue = ""
        timeLabel.stringValue = ""
    }
}

func timeInterval(from string: String) -> TimeInterval? {
    
    let parts = string.components(separatedBy: ":")
    
    guard parts.count == 2 else {
        return nil
    }
    
    return parts
        .reversed()
        .enumerated()
        .reduce(TimeInterval(0)) {
            (result, enumeration) -> TimeInterval? in
            guard let part = Double(enumeration.element), let result = result else {
                return nil
            }
            let intIndex: Int = enumeration.offset
            return result + part * pow(Double(60), Double(intIndex + 1))
    }
}

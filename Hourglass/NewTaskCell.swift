import AppKit

typealias NewTaskAction = (String, HGDuration?) -> Void

class NewTaskCell: NSCollectionViewItem {
    
    @IBOutlet fileprivate var taskNameLabel: NSTextField!
    @IBOutlet fileprivate var timeLabel: NSTextField!
    var onReturn: NewTaskAction = {_,_ in  }
    
    @IBAction func add(_ sender: NSTextField) {
        onReturn(taskNameLabel.stringValue, timeInterval(from: timeLabel.stringValue))
        taskNameLabel.stringValue = ""
        timeLabel.stringValue = ""
    }
}

func timeInterval(from string: String) -> HGDuration? {
    
    let parts = string.components(separatedBy: ":")
    
    guard parts.count == 2 else {
        return nil
    }
    
    return parts
        .reversed()
        .enumerated()
        .reduce(HGDuration(0)) {
            (result, enumeration) -> HGDuration? in
            guard let part = Double(enumeration.element), let result = result else {
                return nil
            }
            let intIndex = enumeration.offset
            return result + HGDuration(part * pow(Double(60), Double(intIndex + 1)))
    }
}

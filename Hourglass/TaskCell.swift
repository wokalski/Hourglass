
import AppKit

final class TaskCell: NSCollectionViewItem {
    
    @IBOutlet private var taskNameLabel: NSTextField!
    @IBOutlet private var timeLabel: NSTextField!
    @IBOutlet private var progressIndicator: NSProgressIndicator!
    @IBOutlet private var button: NSButton!
    
    var viewModel: TaskCellViewModel? = nil {
        didSet {
            if let viewModel = viewModel {
                taskNameLabel.textColor = viewModel.textColor
                timeLabel.textColor = viewModel.textColor
                view.layer?.backgroundColor = viewModel.backgroundColor
                timeLabel.stringValue = viewModel.timeText
                taskNameLabel.stringValue = viewModel.name
                progressIndicator.doubleValue = viewModel.progress
                button.image = viewModel.buttonImage
            } else {
                taskNameLabel.textColor = nil
                timeLabel.textColor = nil
                view.layer?.backgroundColor = nil
                timeLabel.stringValue = ""
                taskNameLabel.stringValue = ""
                progressIndicator.doubleValue = 0
                button.image = nil
            }
        }
    }
    
    @IBAction func click(sender: NSButton) {
        viewModel?.onClick()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
    }
}

class Separator: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor(calibratedRed: 0.6, green: 0.6, blue: 0.6, alpha: 1).setFill()
        NSRectFill(dirtyRect)
    }
}


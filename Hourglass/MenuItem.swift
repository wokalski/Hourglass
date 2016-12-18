import AppKit

class MenuItem: NSMenuItem     {
    typealias Action = (() -> Void)?
    let actionClosure: Action
    
    init(title: String, keyEquivalent: String, actionClosure closure: Action) {
        self.actionClosure = closure
        let selector: Selector? = (closure != nil) ? #selector(fireAction(sender:)) : nil
        super.init(title: title,
                   action: selector,
                   keyEquivalent: keyEquivalent)
        self.target = self
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fireAction(sender: NSMenuItem) {
        actionClosure?()
    }
}

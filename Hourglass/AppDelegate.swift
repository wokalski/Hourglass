//
//  AppDelegate.swift
//  TimeBudget
//
//  Created by Wojciech Czekalski on 05.08.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import Cocoa
import EventKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem: NSStatusItem
    let viewController: ViewController = {
        let bundle = Bundle(for: ViewController.self)
        let storyboard = NSStoryboard(name: "TasksController", bundle: bundle)
        return storyboard.instantiateInitialController() as! ViewController
    }()
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        let bundle = Bundle(for: ViewController.self)
        let storyboard = NSStoryboard(name: "TasksController", bundle: bundle)
        popover.contentViewController = self.viewController
        return popover
    }()
    
    var menu: NSMenu {
        let menu = NSMenu(title: "")
        let item = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        menu.addItem(item)
        menu.addItem(calendarsItem(store: viewController.store))
        return menu
    }
    var monitor: AnyObject?
    
    override init() {
        statusItem = NSStatusBar.system().statusItem(withLength: 30)
        statusItem.alternateImage = #imageLiteral(resourceName: "AlternateIcon")
        statusItem.image = #imageLiteral(resourceName: "Icon")
        statusItem.action = #selector(togglePopover(sender:))
        statusItem.sendAction(on: [.leftMouseUp, .rightMouseUp])
        super.init()
        self.viewController.store.dispatch(action: .Init)
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
            if let monitor = self.monitor {
              NSEvent.removeMonitor(monitor)  
            }
        } else {
            if shouldShowPopover() {
                if let button = statusItem.button {
                    monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown], handler: { [weak self] _ in
                        self?.togglePopover(sender: self)
                    })
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                }
            } else {
                statusItem.popUpMenu(self.menu)
            }
        }
    }
    
    func quit() {
        NSApp.terminate(self)
    }
}

func shouldShowPopover() -> Bool {
    let event = NSApp.currentEvent
    if let event = event {
        let click = event.associatedEventsMask
        let modifier = event.modifierFlags
        let rightClick = click.contains(.rightMouseUp)
        let optionClick = modifier.contains(.option)
        if rightClick || optionClick {
            return false
        }
    }
    return true
}



//
//  AppDelegate.swift
//  TimeBudget
//
//  Created by Wojciech Czekalski on 05.08.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem: NSStatusItem
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        let bundle = Bundle(for: ViewController.self)
        let storyboard = NSStoryboard(name: "TasksController", bundle: bundle)
        popover.contentViewController = storyboard.instantiateInitialController() as! ViewController
        return popover
    }()
    lazy var quitItem: NSMenuItem = {
        return NSMenuItem()
    }()
    lazy var menu: NSMenu = {
        let menu = NSMenu(title: "")
        let item = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        menu.addItem(item)
        return menu
    }()
    
    override init() {
        statusItem = NSStatusBar.system().statusItem(withLength: 30)
        statusItem.alternateImage = #imageLiteral(resourceName: "AlternateIcon")
        statusItem.image = #imageLiteral(resourceName: "Icon")
        statusItem.action = #selector(togglePopover(sender:))
        statusItem.sendAction(on: [.leftMouseUp, .rightMouseUp])
        super.init()
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if shouldShowPopover() {
                if let button = statusItem.button {
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


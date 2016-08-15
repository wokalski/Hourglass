import AppKit
import EventKit

func calendarsItem(store: Store) -> NSMenuItem {
    let item = NSMenuItem(title: "Record work", action: nil, keyEquivalent: "")
    let submenu = NSMenu()
    calendarsMenuItems(for: calendarAuthorizationStatus(), store)
        .forEach { submenu.addItem($0) }
    item.submenu = submenu
    return item
}

func calendarAuthorizationStatus() -> EKAuthorizationStatus {
    return EKEventStore.authorizationStatus(for: .event)
}

func calendarsMenuItems(for status: EKAuthorizationStatus, _ store: Store) -> [NSMenuItem] {
    switch status {
    case .restricted, .denied:
        return [requestPermissionInSettings()]
    case .authorized:
        return allCalendars(store: store)
    case .notDetermined:
        return [requestPermissionItem()]
    }
}

func requestPermissionItem() -> MenuItem {
    return MenuItem(title: "Give permission", keyEquivalent: "", actionClosure: { 
        EKEventStore().requestAccess(to: .event) { _, _ in }
    })
}

func requestPermissionInSettings() -> MenuItem {
    return MenuItem(title: "Enable in Settings -> Privacy -> Calendar", keyEquivalent: "", actionClosure: nil)
}

func allCalendars(store: Store) -> [NSMenuItem] {
    let resetItem = resetSelectedCalendarItem(store: store)
    let eventStore = EKEventStore()
    let calendars = eventStore.calendars(for: .event)
    let calendarItems = calendars
        .filter {
            return $0.mutable
        }
        .map {
            return item(from: $0, eventStore, store)
        }
    let separator = NSMenuItem.separator()
    return [resetItem, separator] + calendarItems
}

func resetSelectedCalendarItem(store: Store) -> NSMenuItem {
    let item = MenuItem(title: "Don't log tasks", keyEquivalent: "", actionClosure: { [weak store] in
        store?.dispatch(action: .Calendar(action: .chooseDefault(logTarget: nil)))
    })
    
    if store.state.logTarget == nil {
        item.state = NSOnState
    } else {
        item.state = NSOffState
    }
    
    return item
}

func item(from
    calendar: EKCalendar,
    _ eventStore: EKEventStore,
    _ store: Store) -> NSMenuItem {
    let dispatch = store.dispatch
    let logTarget = EventLogTarget(calendar: calendar, eventStore: eventStore)
    let item = MenuItem(title: calendar.title,
                    keyEquivalent: "",
                    actionClosure: {
                        dispatch(action: .Calendar(action: .chooseDefault(logTarget: logTarget)))
    })
    
    if store.state.logTarget?.calendar.calendarIdentifier == calendar.calendarIdentifier {
        item.state = NSOnState
    } else {
        item.state = NSOffState
    }
    return item
}

import Foundation
import EventKit

func handleCalendarAction(_ dispatch: Dispatch, _ state: State, _ action: CalendarAction) {
    let calendarIDDefaultsKey = "HGEventCalendarID"
    
    switch action {
    case .chooseDefault(let logTarget):
        UserDefaults.standard.set(logTarget?.calendar.calendarIdentifier, forKey: calendarIDDefaultsKey)
    case let .logTask(task, startTime):
        guard let logTarget = state.logTarget else {
            return
        }
        
        let event = EKEvent(eventStore: logTarget.eventStore)
        let now = Date()
        event.title = task.name
        event.endDate = now
        event.startDate = now.addingTimeInterval(-(Double(HGDuration.subtractWithOverflow(task.timeElapsed, startTime).0)))
        event.calendar = logTarget.calendar
        do {
            try logTarget.eventStore.save(event, span: .thisEvent, commit: true)
        } catch {
            print("Added event from another event store")
            fatalError()
        }
    case .initDefault:
        let eventStore = EKEventStore()
        if let defaultCalendarID = UserDefaults.standard.string(forKey: calendarIDDefaultsKey),
            let calendar = eventStore.calendar(withIdentifier: defaultCalendarID),
            calendar.mutable == true {
            let logTarget = EventLogTarget(calendar: calendar, eventStore: eventStore)
            dispatch(action: .Calendar(action: .chooseDefault(logTarget: logTarget)))
        }
    }
}

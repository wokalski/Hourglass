import EventKit

extension EKCalendar {
    var mutable: Bool {
        return !isImmutable && allowsContentModifications
    }
}

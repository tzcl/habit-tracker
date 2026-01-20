import Foundation

extension Calendar {
    /// Returns the start and end dates of the week containing the given date
    func weekDateRange(containing date: Date) -> (start: Date, end: Date) {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let startOfWeek = self.date(from: components)!
        let endOfWeek = self.date(byAdding: .day, value: 7, to: startOfWeek)!
        return (startOfWeek, endOfWeek)
    }

    /// Returns an array of dates for each day in the week containing the given date
    func datesForWeek(containing date: Date) -> [Date] {
        let (startOfWeek, _) = weekDateRange(containing: date)
        return (0..<7).map { dayOffset in
            self.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
        }
    }

    /// Returns the day index (0-6) within the week for the given date
    func dayIndexInWeek(for date: Date) -> Int {
        let weekday = component(.weekday, from: date)
        let firstWeekday = self.firstWeekday
        return (weekday - firstWeekday + 7) % 7
    }

    /// Returns short day symbols starting from the locale's first day of week
    func orderedWeekdaySymbols(style: WeekdaySymbolStyle = .veryShort) -> [String] {
        let symbols: [String]
        switch style {
        case .veryShort:
            symbols = veryShortWeekdaySymbols
        case .short:
            symbols = shortWeekdaySymbols
        case .full:
            symbols = weekdaySymbols
        }

        let firstWeekday = self.firstWeekday - 1 // Convert to 0-indexed
        return Array(symbols[firstWeekday...]) + Array(symbols[..<firstWeekday])
    }

    enum WeekdaySymbolStyle {
        case veryShort  // S, M, T, W, T, F, S
        case short      // Sun, Mon, Tue, Wed, Thu, Fri, Sat
        case full       // Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
    }
}

extension Date {
    /// Returns true if this date is the same calendar day as another date
    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }

    /// Returns true if this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

import Foundation
import SwiftData

@Model
final class Completion {
    var id: UUID
    var date: Date
    var habit: Habit?

    init(date: Date, habit: Habit) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.habit = habit
    }
}

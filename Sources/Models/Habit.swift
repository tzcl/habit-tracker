import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var targetPerWeek: Int
    var colorIndex: Int
    var createdAt: Date
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \Completion.habit)
    var completions: [Completion] = []

    init(
        name: String,
        targetPerWeek: Int,
        colorIndex: Int,
        sortOrder: Int
    ) {
        self.id = UUID()
        self.name = name
        self.targetPerWeek = targetPerWeek
        self.colorIndex = colorIndex
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }

    // MARK: - Computed Properties

    var color: HabitColor {
        HabitColor.allCases[colorIndex % HabitColor.allCases.count]
    }

    // MARK: - Completion Helpers

    func completionsForWeek(containing date: Date, calendar: Calendar = .current) -> [Completion] {
        let weekRange = calendar.weekDateRange(containing: date)
        return completions.filter { completion in
            completion.date >= weekRange.start && completion.date < weekRange.end
        }
    }

    func completionCountForWeek(containing date: Date, calendar: Calendar = .current) -> Int {
        completionsForWeek(containing: date, calendar: calendar).count
    }

    func isCompletedOn(date: Date, calendar: Calendar = .current) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        return completions.contains { calendar.startOfDay(for: $0.date) == startOfDay }
    }

    func completionFor(date: Date, calendar: Calendar = .current) -> Completion? {
        let startOfDay = calendar.startOfDay(for: date)
        return completions.first { calendar.startOfDay(for: $0.date) == startOfDay }
    }

    func isGoalMetForWeek(containing date: Date, calendar: Calendar = .current) -> Bool {
        completionCountForWeek(containing: date, calendar: calendar) >= targetPerWeek
    }
}

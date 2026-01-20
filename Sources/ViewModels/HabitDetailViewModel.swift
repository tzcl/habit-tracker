import Foundation
import SwiftData
import SwiftUI

@Observable
final class HabitDetailViewModel {
    private let modelContext: ModelContext
    private let calendar: Calendar

    let habit: Habit
    var errorMessage: String?

    private var onDelete: (() -> Void)?

    init(habit: Habit, modelContext: ModelContext, calendar: Calendar = .current, onDelete: (() -> Void)? = nil) {
        self.habit = habit
        self.modelContext = modelContext
        self.calendar = calendar
        self.onDelete = onDelete
    }

    // MARK: - Habit Properties (auto-save on change)

    var name: String {
        get { habit.name }
        set {
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty && trimmed.count <= 50 else { return }
            habit.name = trimmed
            saveContext()
        }
    }

    var targetPerWeek: Int {
        get { habit.targetPerWeek }
        set {
            guard newValue >= 1 && newValue <= 7 else { return }
            habit.targetPerWeek = newValue
            saveContext()
        }
    }

    var color: HabitColor {
        get { habit.color }
        set {
            habit.colorIndex = newValue.rawValue
            saveContext()
        }
    }

    // MARK: - Week Data

    func weekDates(for date: Date = Date()) -> [Date] {
        calendar.datesForWeek(containing: date)
    }

    func completionCount(for date: Date = Date()) -> Int {
        habit.completionCountForWeek(containing: date, calendar: calendar)
    }

    func isCompletedOn(_ date: Date) -> Bool {
        habit.isCompletedOn(date: date, calendar: calendar)
    }

    func isGoalMet(for date: Date = Date()) -> Bool {
        habit.isGoalMetForWeek(containing: date, calendar: calendar)
    }

    // MARK: - Actions

    func toggleCompletion(for date: Date) {
        let wasGoalMetBefore = isGoalMet()

        if let existingCompletion = habit.completionFor(date: date, calendar: calendar) {
            modelContext.delete(existingCompletion)
            HapticManager.shared.uncheckTap()
        } else {
            let completion = Completion(date: date, habit: habit)
            modelContext.insert(completion)

            let isGoalMetNow = completionCount() + 1 >= habit.targetPerWeek

            if !wasGoalMetBefore && isGoalMetNow {
                HapticManager.shared.goalAchieved()
            } else {
                HapticManager.shared.completionTap()
            }
        }

        saveContext()
    }

    func deleteHabit() {
        modelContext.delete(habit)
        saveContext()
        onDelete?()
    }

    // MARK: - Validation

    func isNameValid(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 50
    }

    func isNameUnique(_ name: String, allHabits: [Habit]) -> Bool {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return !allHabits.contains { existingHabit in
            guard existingHabit.id != habit.id else { return false }
            return existingHabit.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalizedName
        }
    }

    // MARK: - Private

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Unable to save. Please try again."
        }
    }
}

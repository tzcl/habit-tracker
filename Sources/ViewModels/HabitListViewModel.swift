import Foundation
import SwiftData
import SwiftUI

@Observable
final class HabitListViewModel {
    private let modelContext: ModelContext
    private let calendar: Calendar

    var habits: [Habit] = []
    var currentDate: Date = Date()
    var showingAddHabit = false
    var errorMessage: String?

    init(modelContext: ModelContext, calendar: Calendar = .current) {
        self.modelContext = modelContext
        self.calendar = calendar
        fetchHabits()
    }

    // MARK: - Fetching

    func fetchHabits() {
        let descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
        )

        do {
            habits = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Unable to load habits. Please try again."
            habits = []
        }
    }

    // MARK: - Habit Management

    func addHabit(name: String, targetPerWeek: Int) {
        let colorIndex = habits.count % HabitColor.allCases.count
        let sortOrder = (habits.map(\.sortOrder).max() ?? -1) + 1

        let habit = Habit(
            name: name,
            targetPerWeek: targetPerWeek,
            colorIndex: colorIndex,
            sortOrder: sortOrder
        )

        modelContext.insert(habit)
        saveContext()
        fetchHabits()
    }

    func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        saveContext()
        fetchHabits()
    }

    // MARK: - Completion Management

    func toggleCompletion(for habit: Habit, on date: Date = Date()) {
        let wasGoalMetBefore = habit.isGoalMetForWeek(containing: date, calendar: calendar)

        if let existingCompletion = habit.completionFor(date: date, calendar: calendar) {
            // Uncomplete: remove the completion
            modelContext.delete(existingCompletion)
            HapticManager.shared.uncheckTap()
        } else {
            // Complete: add new completion
            let completion = Completion(date: date, habit: habit)
            modelContext.insert(completion)

            let isGoalMetNow = habit.completionCountForWeek(containing: date, calendar: calendar) + 1 >= habit.targetPerWeek

            if !wasGoalMetBefore && isGoalMetNow {
                HapticManager.shared.goalAchieved()
            } else {
                HapticManager.shared.completionTap()
            }
        }

        saveContext()
    }

    // MARK: - Validation

    func isHabitNameUnique(_ name: String, excluding habit: Habit? = nil) -> Bool {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return !habits.contains { existingHabit in
            guard existingHabit.id != habit?.id else { return false }
            return existingHabit.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalizedName
        }
    }

    // MARK: - Week Helpers

    func weekDates() -> [Date] {
        calendar.datesForWeek(containing: currentDate)
    }

    func refreshCurrentDate() {
        currentDate = Date()
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

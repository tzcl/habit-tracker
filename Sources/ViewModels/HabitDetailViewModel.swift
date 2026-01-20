import Foundation
import SwiftData
import SwiftUI

@Observable
final class HabitDetailViewModel {
    private let modelContext: ModelContext
    private let calendar: Calendar

    let habit: Habit

    var editedName: String
    var editedTargetPerWeek: Int
    var showingDeleteConfirmation = false
    var errorMessage: String?

    private var onDelete: (() -> Void)?

    init(habit: Habit, modelContext: ModelContext, calendar: Calendar = .current, onDelete: (() -> Void)? = nil) {
        self.habit = habit
        self.modelContext = modelContext
        self.calendar = calendar
        self.onDelete = onDelete

        self.editedName = habit.name
        self.editedTargetPerWeek = habit.targetPerWeek
    }

    // MARK: - Computed Properties

    var hasUnsavedChanges: Bool {
        editedName != habit.name || editedTargetPerWeek != habit.targetPerWeek
    }

    var isNameValid: Bool {
        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 50
    }

    var isTargetValid: Bool {
        editedTargetPerWeek >= 1 && editedTargetPerWeek <= 7
    }

    var canSave: Bool {
        hasUnsavedChanges && isNameValid && isTargetValid
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

    func saveChanges() {
        guard canSave else { return }

        habit.name = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        habit.targetPerWeek = editedTargetPerWeek

        saveContext()
    }

    func discardChanges() {
        editedName = habit.name
        editedTargetPerWeek = habit.targetPerWeek
    }

    func deleteHabit() {
        modelContext.delete(habit)
        saveContext()
        onDelete?()
    }

    // MARK: - Validation

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

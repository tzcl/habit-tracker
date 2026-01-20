import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let habit: Habit
    let allHabits: [Habit]
    let onDelete: () -> Void

    @State private var viewModel: HabitDetailViewModel?
    @State private var showingDeleteConfirmation = false

    private let calendar = Calendar.current

    var body: some View {
        Group {
            if let viewModel {
                detailContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Habit Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let viewModel, viewModel.canSave {
                    Button("Save") {
                        viewModel.saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Delete Habit?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel?.deleteHabit()
            }
        } message: {
            Text("This will permanently delete \"\(habit.name)\" and all its completion history.")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HabitDetailViewModel(
                    habit: habit,
                    modelContext: modelContext,
                    onDelete: onDelete
                )
            }
        }
    }

    // MARK: - Detail Content

    @ViewBuilder
    private func detailContent(viewModel: HabitDetailViewModel) -> some View {
        Form {
            // Edit Section
            Section {
                TextField("Habit name", text: Binding(
                    get: { viewModel.editedName },
                    set: { viewModel.editedName = $0 }
                ))
                .onChange(of: viewModel.editedName) { _, newValue in
                    if newValue.count > 50 {
                        viewModel.editedName = String(newValue.prefix(50))
                    }
                }

                if !viewModel.editedName.isEmpty && !viewModel.isNameValid {
                    Text(nameValidationError(viewModel: viewModel))
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Stepper(value: Binding(
                    get: { viewModel.editedTargetPerWeek },
                    set: { viewModel.editedTargetPerWeek = $0 }
                ), in: 1...7) {
                    HStack {
                        Text("Target")
                        Spacer()
                        Text("\(viewModel.editedTargetPerWeek)× per week")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Details")
            }

            // This Week Section
            Section {
                weekProgressView(viewModel: viewModel)
            } header: {
                Text("This Week")
            } footer: {
                Text("Tap a day to toggle completion")
            }

            // Stats Section
            Section {
                HStack {
                    Text("Progress")
                    Spacer()
                    Text("\(viewModel.completionCount()) / \(habit.targetPerWeek)")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Status")
                    Spacer()
                    if viewModel.isGoalMet() {
                        Label("Goal Met", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(habit.color.color)
                    } else {
                        let remaining = habit.targetPerWeek - viewModel.completionCount()
                        Text("\(remaining) more to go")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Stats")
            }

            // Delete Section
            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Habit")
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Week Progress View

    @ViewBuilder
    private func weekProgressView(viewModel: HabitDetailViewModel) -> some View {
        let weekDates = viewModel.weekDates()
        let daySymbols = calendar.orderedWeekdaySymbols(style: .veryShort)

        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(Array(zip(weekDates, daySymbols)), id: \.0) { date, symbol in
                dayButton(
                    date: date,
                    symbol: symbol,
                    isCompleted: viewModel.isCompletedOn(date),
                    viewModel: viewModel
                )
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func dayButton(
        date: Date,
        symbol: String,
        isCompleted: Bool,
        viewModel: HabitDetailViewModel
    ) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()

        Button {
            if !isFuture {
                viewModel.toggleCompletion(for: date)
            }
        } label: {
            VStack(spacing: 4) {
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                ZStack {
                    Circle()
                        .fill(isCompleted ? habit.color.color : Color.gray.opacity(0.15))
                        .frame(width: 36, height: 36)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    if isToday && !isCompleted {
                        Circle()
                            .strokeBorder(habit.color.color, lineWidth: 2)
                            .frame(width: 36, height: 36)
                    }
                }
                .animation(AnimationConstants.quickSpring, value: isCompleted)
            }
            .opacity(isFuture ? 0.4 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
        .accessibilityLabel("\(symbol), \(isCompleted ? "completed" : "not completed")\(isToday ? ", today" : "")")
        .accessibilityHint(isFuture ? "Future date" : (isCompleted ? "Double tap to mark incomplete" : "Double tap to mark complete"))
    }

    // MARK: - Helpers

    private func nameValidationError(viewModel: HabitDetailViewModel) -> String {
        let trimmed = viewModel.editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Name cannot be empty"
        }
        if !viewModel.isNameUnique(viewModel.editedName, allHabits: allHabits) {
            return "A habit with this name already exists"
        }
        return ""
    }
}

#Preview {
    Text("Preview requires model context and habit")
}

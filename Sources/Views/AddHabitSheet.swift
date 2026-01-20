import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: HabitListViewModel

    @State private var habitName = ""
    @State private var targetPerWeek = 3
    @State private var selectedColor: HabitColor = .coral
    @FocusState private var isNameFieldFocused: Bool

    private let maxNameLength = 50

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Habit name", text: $habitName)
                        .focused($isNameFieldFocused)
                        .onChange(of: habitName) { _, newValue in
                            if newValue.count > maxNameLength {
                                habitName = String(newValue.prefix(maxNameLength))
                            }
                        }
                        .accessibilityLabel("Habit name")

                    if !habitName.isEmpty && !isNameValid {
                        Text(validationErrorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Name")
                } footer: {
                    Text("\(habitName.count)/\(maxNameLength) characters")
                        .font(.caption)
                }

                Section {
                    Stepper(value: $targetPerWeek, in: 1...7) {
                        HStack {
                            Text("Target")
                            Spacer()
                            Text("\(targetPerWeek)× per week")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityValue("\(targetPerWeek) times per week")
                } header: {
                    Text("Weekly Goal")
                } footer: {
                    Text("How many times per week do you want to complete this habit?")
                }

                Section {
                    ColorPickerGrid(selectedColor: $selectedColor)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
        .interactiveDismissDisabled(!habitName.isEmpty)
    }

    // MARK: - Validation

    private var trimmedName: String {
        habitName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isNameValid: Bool {
        !trimmedName.isEmpty && isNameUnique
    }

    private var isNameUnique: Bool {
        viewModel.isHabitNameUnique(trimmedName)
    }

    private var canSave: Bool {
        isNameValid && targetPerWeek >= 1 && targetPerWeek <= 7
    }

    private var validationErrorMessage: String {
        if trimmedName.isEmpty {
            return "Name cannot be empty"
        }
        if !isNameUnique {
            return "A habit with this name already exists"
        }
        return ""
    }

    // MARK: - Actions

    private func saveHabit() {
        guard canSave else { return }
        viewModel.addHabit(name: trimmedName, targetPerWeek: targetPerWeek, color: selectedColor)
        dismiss()
    }
}

#Preview {
    Text("Preview requires model context")
}

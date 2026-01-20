import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var viewModel: HabitListViewModel?
    @State private var selectedHabit: Habit?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if let viewModel {
                    if viewModel.habits.isEmpty {
                        emptyStateView
                    } else {
                        habitListContent(viewModel: viewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let viewModel, !viewModel.habits.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel?.showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("Add habit")
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showingAddHabit ?? false },
                set: { viewModel?.showingAddHabit = $0 }
            )) {
                if let viewModel {
                    AddHabitSheet(viewModel: viewModel)
                }
            }
            .navigationDestination(for: Habit.ID.self) { habitId in
                if let viewModel, let habit = viewModel.habits.first(where: { $0.id == habitId }) {
                    HabitDetailView(
                        habit: habit,
                        allHabits: viewModel.habits,
                        onDelete: {
                            navigationPath.removeLast()
                            viewModel.fetchHabits()
                        }
                    )
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HabitListViewModel(modelContext: modelContext)
            }
            viewModel?.refreshCurrentDate()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel?.refreshCurrentDate()
                viewModel?.fetchHabits()
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Habits Yet", systemImage: "list.bullet.clipboard")
        } description: {
            Text("Add your first habit to start tracking your weekly progress.")
        } actions: {
            Button {
                viewModel?.showingAddHabit = true
            } label: {
                Text("Add Habit")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Habit List

    @ViewBuilder
    private func habitListContent(viewModel: HabitListViewModel) -> some View {
        List {
            ForEach(viewModel.habits) { habit in
                HabitCardView(
                    habit: habit,
                    weekDates: viewModel.weekDates(),
                    onDateTap: { date in
                        viewModel.toggleCompletion(for: habit, on: date)
                    },
                    onTap: {
                        navigationPath.append(habit.id)
                    }
                )
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onMove { source, destination in
                viewModel.moveHabit(from: source, to: destination)
            }
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
        .scrollContentBackground(.hidden)
        .refreshable {
            viewModel.refreshCurrentDate()
            viewModel.fetchHabits()
        }
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: [Habit.self, Completion.self], inMemory: true)
}

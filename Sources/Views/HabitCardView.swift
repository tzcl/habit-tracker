import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let weekDates: [Date]
    let onDateTap: (Date) -> Void
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showGoalCelebration = false

    private let calendar = Calendar.current

    init(
        habit: Habit,
        weekDates: [Date],
        onDateTap: @escaping (Date) -> Void,
        onTap: @escaping () -> Void
    ) {
        self.habit = habit
        self.weekDates = weekDates
        self.onDateTap = onDateTap
        self.onTap = onTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with habit name and progress
            HStack {
                Text(habit.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                if isGoalMet {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(habit.color.color)
                        .imageScale(.medium)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            // Week indicator with circles
            WeekIndicatorView(
                weekDates: weekDates,
                completedDates: completedDatesSet,
                accentColor: habit.color.color,
                calendar: calendar,
                onDateTap: handleDateTap
            )

            // Progress text
            Text(progressText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(habit.color.backgroundColor)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .overlay {
            if showGoalCelebration {
                goalCelebrationOverlay
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Computed Properties

    private var completedDatesSet: Set<Date> {
        Set(habit.completionsForWeek(containing: Date(), calendar: calendar).map(\.date))
    }

    private var completionCount: Int {
        habit.completionCountForWeek(containing: Date(), calendar: calendar)
    }

    private var isGoalMet: Bool {
        completionCount >= habit.targetPerWeek
    }

    private var progressText: String {
        "\(completionCount) / \(habit.targetPerWeek) this week"
    }

    private var accessibilityLabel: String {
        let status = isGoalMet ? "Goal met" : "\(completionCount) of \(habit.targetPerWeek) completed this week"
        return "\(habit.name), \(status)"
    }

    // MARK: - Actions

    private func handleDateTap(_ date: Date) {
        let wasGoalMet = isGoalMet

        onDateTap(date)

        // Check if goal was just achieved
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let isNowGoalMet = habit.completionCountForWeek(containing: Date(), calendar: calendar) >= habit.targetPerWeek

            if !wasGoalMet && isNowGoalMet {
                triggerGoalCelebration()
            }
        }
    }

    private func triggerGoalCelebration() {
        guard !reduceMotion else { return }

        withAnimation(AnimationConstants.quickSpring) {
            showGoalCelebration = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(AnimationConstants.standardSpring) {
                showGoalCelebration = false
            }
        }
    }

    // MARK: - Celebration Overlay

    @ViewBuilder
    private var goalCelebrationOverlay: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [habit.color.color.opacity(0.3), habit.color.color.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .mask {
                shimmerMask
            }
    }

    private var shimmerMask: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: geometry.size.width * 0.5)
                .offset(x: showGoalCelebration ? geometry.size.width * 1.5 : -geometry.size.width * 0.5)
                .animation(
                    .easeInOut(duration: 0.6),
                    value: showGoalCelebration
                )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("HabitCardView Preview")
            .padding()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

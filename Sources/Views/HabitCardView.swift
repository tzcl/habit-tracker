import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let weekDates: [Date]
    let onTap: () -> Void
    let onLongPress: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false
    @State private var showGoalCelebration = false

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Habit name
            Text(habit.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)

            // Week indicator
            WeekIndicatorView(
                weekDates: weekDates,
                completedDates: completedDatesSet,
                accentColor: habit.color.color,
                calendar: calendar
            )

            // Progress text
            HStack {
                Text(progressText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())

                Spacer()

                if isGoalMet {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(habit.color.color)
                        .imageScale(.small)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .overlay {
            if showGoalCelebration {
                goalCelebrationOverlay
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(
            reduceMotion ? AnimationConstants.reducedMotion : AnimationConstants.quickSpring,
            value: isPressed
        )
        .onTapGesture {
            handleTap()
        }
        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
            withAnimation(AnimationConstants.quickSpring) {
                isPressed = pressing
            }
        }) {
            onLongPress()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isTodayCompleted ? "Double tap to mark incomplete" : "Double tap to mark complete")
        .accessibilityAddTraits(.isButton)
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

    private var isTodayCompleted: Bool {
        habit.isCompletedOn(date: Date(), calendar: calendar)
    }

    private var progressText: String {
        "\(completionCount) / \(habit.targetPerWeek) this week"
    }

    private var accessibilityLabel: String {
        let status = isGoalMet ? "Goal met" : "\(completionCount) of \(habit.targetPerWeek) completed this week"
        let todayStatus = isTodayCompleted ? "Today completed" : "Today not completed"
        return "\(habit.name), \(status), \(todayStatus)"
    }

    // MARK: - Actions

    private func handleTap() {
        let wasGoalMet = isGoalMet

        onTap()

        // Check if goal was just achieved
        let isNowGoalMet = habit.completionCountForWeek(containing: Date(), calendar: calendar) >= habit.targetPerWeek

        if !wasGoalMet && isNowGoalMet {
            triggerGoalCelebration()
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
        // This would need actual Habit instances in a real preview
        Text("HabitCardView Preview")
            .padding()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

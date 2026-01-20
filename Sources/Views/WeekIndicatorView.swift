import SwiftUI
import UIKit

struct WeekIndicatorView: View {
    let weekDates: [Date]
    let completedDates: Set<Date>
    let accentColor: Color
    let calendar: Calendar
    let onDateTap: ((Date) -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let circleSize: CGFloat = 32

    init(
        weekDates: [Date],
        completedDates: Set<Date>,
        accentColor: Color,
        calendar: Calendar = .current,
        onDateTap: ((Date) -> Void)? = nil
    ) {
        self.weekDates = weekDates
        self.completedDates = completedDates
        self.accentColor = accentColor
        self.calendar = calendar
        self.onDateTap = onDateTap
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                let isCompleted = isDateCompleted(date)
                let isToday = calendar.isDateInToday(date)

                dayCircleView(
                    date: date,
                    isCompleted: isCompleted,
                    isToday: isToday
                )

                if index < weekDates.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
    }

    @ViewBuilder
    private func dayCircleView(
        date: Date,
        isCompleted: Bool,
        isToday: Bool
    ) -> some View {
        let dayLetter = dayOfWeekLetter(for: date)

        Button {
            onDateTap?(date)
        } label: {
            VStack(spacing: 4) {
                Text(dayLetter)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(isToday ? accentColor : .secondary)

                Circle()
                    .fill(isCompleted ? accentColor : Color.gray.opacity(0.2))
                    .frame(width: circleSize, height: circleSize)
                    .overlay {
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        } else if isToday {
                            Circle()
                                .strokeBorder(accentColor.opacity(0.5), lineWidth: 2)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .animation(
            reduceMotion ? AnimationConstants.reducedMotion : AnimationConstants.segmentFill,
            value: isCompleted
        )
        .accessibilityLabel("\(fullDayName(for: date)), \(isCompleted ? "completed" : "not completed")")
        .accessibilityHint("Tap to toggle completion")
    }

    private func isDateCompleted(_ date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        return completedDates.contains { calendar.startOfDay(for: $0) == startOfDay }
    }

    private func dayOfWeekLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }

    private func fullDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 30) {
        // Empty week
        WeekIndicatorView(
            weekDates: Calendar.current.datesForWeek(containing: Date()),
            completedDates: [],
            accentColor: HabitColor.coral.color
        ) { date in
            print("Tapped: \(date)")
        }

        // Partially complete
        WeekIndicatorView(
            weekDates: Calendar.current.datesForWeek(containing: Date()),
            completedDates: Set([Date(), Calendar.current.date(byAdding: .day, value: -1, to: Date())!]),
            accentColor: HabitColor.teal.color
        ) { date in
            print("Tapped: \(date)")
        }

        // Fully complete
        WeekIndicatorView(
            weekDates: Calendar.current.datesForWeek(containing: Date()),
            completedDates: Set(Calendar.current.datesForWeek(containing: Date())),
            accentColor: HabitColor.indigo.color
        ) { date in
            print("Tapped: \(date)")
        }
    }
    .padding()
}

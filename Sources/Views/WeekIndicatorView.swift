import SwiftUI
import UIKit

struct WeekIndicatorView: View {
    let weekDates: [Date]
    let completedDates: Set<Date>
    let accentColor: Color
    let calendar: Calendar

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let segmentSpacing: CGFloat = 2
    private let cornerRadius: CGFloat = 6

    init(
        weekDates: [Date],
        completedDates: Set<Date>,
        accentColor: Color,
        calendar: Calendar = .current
    ) {
        self.weekDates = weekDates
        self.completedDates = completedDates
        self.accentColor = accentColor
        self.calendar = calendar
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: segmentSpacing) {
                ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                    let isCompleted = isDateCompleted(date)
                    let isToday = calendar.isDateInToday(date)

                    segmentView(
                        isCompleted: isCompleted,
                        isToday: isToday,
                        isFirst: index == 0,
                        isLast: index == weekDates.count - 1
                    )
                }
            }
        }
        .frame(height: 12)
    }

    @ViewBuilder
    private func segmentView(
        isCompleted: Bool,
        isToday: Bool,
        isFirst: Bool,
        isLast: Bool
    ) -> some View {
        let corners = segmentCorners(isFirst: isFirst, isLast: isLast)

        RoundedCornersShape(radius: cornerRadius, corners: corners)
            .fill(isCompleted ? accentColor : Color.gray.opacity(0.2))
            .overlay {
                if isToday && !isCompleted {
                    RoundedCornersShape(radius: cornerRadius, corners: corners)
                        .strokeBorder(accentColor.opacity(0.5), lineWidth: 1.5)
                }
            }
            .animation(
                reduceMotion ? AnimationConstants.reducedMotion : AnimationConstants.segmentFill,
                value: isCompleted
            )
    }

    private func segmentCorners(isFirst: Bool, isLast: Bool) -> UIRectCorner {
        var corners: UIRectCorner = []
        if isFirst {
            corners.insert(.topLeft)
            corners.insert(.bottomLeft)
        }
        if isLast {
            corners.insert(.topRight)
            corners.insert(.bottomRight)
        }
        return corners
    }

    private func isDateCompleted(_ date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        return completedDates.contains { calendar.startOfDay(for: $0) == startOfDay }
    }
}

// MARK: - Custom Shape for Rounded Corners

struct RoundedCornersShape: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension RoundedCornersShape: InsettableShape {
    func inset(by amount: CGFloat) -> some InsettableShape {
        RoundedCornersShape(radius: max(0, radius - amount), corners: corners)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Empty week
        WeekIndicatorView(
            weekDates: Calendar.current.datesForWeek(containing: Date()),
            completedDates: [],
            accentColor: HabitColor.coral.color
        )

        // Partially complete
        WeekIndicatorView(
            weekDates: Calendar.current.datesForWeek(containing: Date()),
            completedDates: Set([Date(), Calendar.current.date(byAdding: .day, value: -1, to: Date())!]),
            accentColor: HabitColor.teal.color
        )

        // Fully complete
        WeekIndicatorView(
            weekDates: Calendar.current.datesForWeek(containing: Date()),
            completedDates: Set(Calendar.current.datesForWeek(containing: Date())),
            accentColor: HabitColor.indigo.color
        )
    }
    .padding()
}

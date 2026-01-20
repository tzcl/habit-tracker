import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        softImpact.prepare()
        notificationGenerator.prepare()
    }

    /// Light tap feedback for completing a day
    func completionTap() {
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }

    /// Success notification for achieving weekly goal
    func goalAchieved() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    /// Soft feedback for unchecking (optional, can be disabled)
    func uncheckTap() {
        softImpact.impactOccurred(intensity: 0.5)
        softImpact.prepare()
    }

    /// Medium impact for general interactions
    func mediumTap() {
        mediumImpact.impactOccurred()
        mediumImpact.prepare()
    }
}

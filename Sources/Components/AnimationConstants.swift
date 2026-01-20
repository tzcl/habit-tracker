import SwiftUI

enum AnimationConstants {
    // MARK: - Spring Animations

    /// Standard spring for most UI interactions
    static let standardSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)

    /// Quick spring for snappy feedback
    static let quickSpring = Animation.spring(response: 0.2, dampingFraction: 0.8)

    /// Bouncy spring for celebratory animations
    static let bouncySpring = Animation.spring(response: 0.4, dampingFraction: 0.6)

    // MARK: - Ease Animations

    /// Segment fill animation
    static let segmentFill = Animation.easeOut(duration: 0.25)

    /// Reduced motion alternative
    static let reducedMotion = Animation.easeInOut(duration: 0.2)

    /// Quick fade for subtle transitions
    static let quickFade = Animation.easeInOut(duration: 0.15)

    // MARK: - Durations

    static let shortDuration: Double = 0.15
    static let standardDuration: Double = 0.25
    static let longDuration: Double = 0.35

    // MARK: - Helpers

    /// Returns appropriate animation based on reduce motion preference
    static func animation(
        standard: Animation = standardSpring,
        reduced: Animation = reducedMotion
    ) -> Animation {
        UIAccessibility.isReduceMotionEnabled ? reduced : standard
    }
}

// MARK: - View Extension for Conditional Animation

extension View {
    /// Applies animation respecting reduce motion setting
    func animateWithReduceMotion(
        _ animation: Animation = AnimationConstants.standardSpring,
        reducedAnimation: Animation = AnimationConstants.reducedMotion
    ) -> some View {
        self.animation(
            UIAccessibility.isReduceMotionEnabled ? reducedAnimation : animation,
            value: UUID() // Note: In practice, use actual changing value
        )
    }
}

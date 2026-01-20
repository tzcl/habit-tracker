PRD: iOS Habit Tracker (Offline, Delight-First)
1) Summary

A beautifully animated iOS habit tracker that makes completing habits feel rewarding. Users see a list of habits as long “progress bars” representing the current week. Tapping a habit toggles completion for “today.” Long-press opens a details screen for editing and deeper viewing. All data is stored locally on-device (no accounts, no cloud, no backend).

2) Goals & Non-goals
Goals (v1)

Create a visually polished, animation-forward habit list UI.

Fast daily interaction: open app → tap habit → get reward animation.

Allow unlimited habits.

Each habit supports a “target times per week” goal.

Store data locally on-device with robust persistence.

Use modern SwiftUI architecture + iOS best practices.

Non-goals (v1)

No login/accounts.

No cloud sync / cross-device sync.

No social/sharing.

No advanced analytics, AI suggestions, or complex scheduling.

No widgets/watch app (leave as future).

3) Target Users

People who want a simple weekly habit checklist with a premium feel.

Users who value aesthetic and motivation from micro-rewards.

4) Core User Stories

As a user, I can add a habit with a weekly goal (e.g., 3x/week).

As a user, I can see all my habits in a list with weekly progress.

As a user, I can tap a habit to mark/unmark completion for today.

As a user, I can long-press a habit to open details.

As a user, I can edit or delete a habit from the details screen.

5) Information Architecture & Key Screens
A) Habit List (Home)

Primary UI: A vertical list of “habit cards” styled as long rounded rectangles.

Each habit card includes:

Habit name (single line, truncated with ellipsis if > ~30 characters visible)

Weekly progress indicator: A single rounded rectangular bar divided into 7 connected segments representing days of the current week. Each segment fills with the habit's assigned color when that day is complete. Incomplete segments show a subtle outline or muted fill.

Text summary: "X / Y this week" (e.g., "2 / 3 this week")

Accent color: Auto-assigned from the 8-color palette (no user selection in v1)

Interaction

Tap: toggles completion for the current day (see behavior rules).

Long press: opens Habit Details.

Empty state

Friendly illustration/animation + “Add your first habit” CTA.

B) Add Habit (Modal)

Presented as a sheet.
Fields:

Habit name (required)

Target times per week (1–7) (required)

Optional: color (v1 optional; can default to automatic palette)

Actions:

Save

Cancel

Validation:

Name must be non-empty.

Name must be unique (case-insensitive comparison; show inline error "A habit with this name already exists").

Name maximum length: 50 characters (enforce in text field).

Target must be 1–7.

Save button disabled until all validation passes.

C) Habit Details (Push navigation)

Accessible via long press on a habit card. (Note: Consider adding a chevron or subtle affordance on cards to hint at details screen for discoverability.)

Shows:

Habit name (editable inline or via Edit mode)

Target times/week (editable)

Weekly view with day-by-day completion state (tap individual days to toggle, not just today)

Delete habit action

Delete confirmation dialog:
- Title: "Delete Habit?"
- Message: "This will permanently delete "[habit name]" and all its completion history."
- Actions: "Cancel" (default), "Delete" (destructive)

Edit validation: Same rules as Add Habit (name non-empty, unique, max 50 chars; target 1–7).

Out of scope for v1: "Reset week" action

6) Weekly Model & Behavior Rules (v1)

Week is defined by the user’s locale calendar (start of week based on locale).

The habit shows 7 day slots (Mon–Sun or locale equivalent).

A “completion” is stored as a boolean for each day of the current week.

Tapping the habit toggles today’s slot:

If today is incomplete → mark complete.

If today is complete → mark incomplete.

Weekly progress count = number of completed days in that week (0–7).

Weekly goal is “times per week” (1–7). The habit is considered “on track” if completedDays >= goal.

Edge cases

If user taps multiple times quickly: debounce or allow but keep state consistent. (Recommendation: allow rapid taps; SwiftData handles consistency.)

If week changes (new week begins): the UI naturally shows a new week with no completions (see persistence strategy).

Timezone handling: Completions are stored with the date in the device's current timezone at time of completion. If user travels, existing completions remain as-is; new completions use the new timezone. This may result in minor inconsistencies across timezone changes, which is acceptable for v1.

Week boundary: "Today" is determined by the device's current calendar and timezone. Week rollover happens at midnight local time.

Locale changes: If user changes their locale (which may change week start day), the week indicator recomputes based on the new locale. Historical completions remain valid since they're stored by absolute date.

7) Reward & Animation Requirements (Delight-First)

The “reward” is a core feature, not polish.

Tap completion (today toggled to complete)

A satisfying micro-animation on the habit card:

Day segment fills with a spring animation.

Subtle glow or confetti-like particle burst (keep lightweight).

Haptic feedback: light/medium impact.

Progress text animates (e.g., “2 / 3” ticks up smoothly).

If the tap causes the habit to hit its weekly goal, trigger a slightly bigger celebration:

More pronounced haptic (success notification)

A brief “goal achieved” accent animation on the card (e.g., shimmer sweep)

Unchecking (toggle to incomplete)

Reverse animation: segment empties smoothly.

Softer haptic (optional) or none.

Motion guidelines

Keep durations short (150–350ms for most transitions).

Animation constants (define in `AnimationConstants.swift`):
- Standard spring: `.spring(response: 0.3, dampingFraction: 0.7)`
- Quick spring: `.spring(response: 0.2, dampingFraction: 0.8)`
- Segment fill: `.easeOut(duration: 0.25)`

Haptic feedback:
- Day completion: `UIImpactFeedbackGenerator(style: .light)`
- Goal achieved: `UINotificationFeedbackGenerator().notificationOccurred(.success)`
- Uncheck: No haptic (or `.soft` if any)

Respect Reduce Motion accessibility setting (`UIAccessibility.isReduceMotionEnabled` or `@Environment(\.accessibilityReduceMotion)`):
- Replace springs with `.easeInOut(duration: 0.2)`
- Disable particle effects
- Keep opacity/scale transitions but shorten to 150ms

8) Data & Persistence (On-device only)

Store locally using a best-practice, Apple-native approach.

Minimum deployment target: iOS 17.0

Persistence framework: SwiftData with @Model and @Observable integration.

Data model:

```
Habit (SwiftData @Model)
├── id: UUID (auto-generated)
├── name: String (max 50 characters, unique, non-empty)
├── targetPerWeek: Int (1–7)
├── colorIndex: Int (index into preset color palette, auto-assigned)
├── createdAt: Date
├── sortOrder: Int (for future reordering support)
└── completions: [Completion] (relationship, cascade delete)

Completion (SwiftData @Model)
├── id: UUID (auto-generated)
├── date: Date (stored as start-of-day in device timezone)
└── habit: Habit (inverse relationship)
```

Color palette (auto-assigned to new habits in rotation):
```
Index  Name    Hex       RGB
0      Coral   #FF6B6B   (255, 107, 107)
1      Amber   #FFAB5E   (255, 171, 94)
2      Lime    #7ED687   (126, 214, 135)
3      Teal    #4ECDC4   (78, 205, 196)
4      Sky     #74B9FF   (116, 185, 255)
5      Indigo  #7C7AE8   (124, 122, 232)
6      Purple  #B388EB   (179, 136, 235)
7      Pink    #FF8FB1   (255, 143, 177)
```
Assignment: `colorIndex = habitCount % 8` at creation time.

Notes:
- Completions are stored by actual date (not week) to future-proof streaks/history.
- When querying current week, filter completions by date range.
- Even if UI only shows current week, storing by date future-proofs streaks/history.

No remote services. No account system.

9) Functional Requirements
Home

List habits (in a stable order; v1 can be creation order).

Each habit card shows:

Name

7-day week indicator

“completed / goal” text

Tap toggles today’s completion.

Long press navigates to details.

Add button in navigation bar trailing position (SF Symbol: `plus`) opens Add Habit sheet.

Add Habit

Create habit with name + target/week.

On save, dismiss and show new habit in list.

If user cancels, no changes.

Details

View weekly completion states.

Edit habit name and target/week.

Delete habit with confirmation dialog.

10) Non-functional Requirements

Performance: 60fps animations on modern iPhones; avoid heavy effects in lists. Target < 16ms frame time for scroll and animations.

Reliability: Local persistence must survive app restarts. SwiftData autosave handles most cases; call explicit save after critical operations (habit creation, deletion).

Error handling:
- Persistence failures (rare with SwiftData): Log error, show non-blocking toast "Unable to save. Please try again."
- If ModelContainer fails to initialize (corrupted data): Show recovery screen offering to reset data (last resort).

Accessibility:
- Dynamic Type support (all text scales)
- VoiceOver labels (e.g., "Exercise, 3 of 5 completed this week, tap to mark today complete")
- Reduce Motion compliance (no jarring motion when enabled)
- Minimum contrast ratio 4.5:1 for text, 3:1 for UI components

Privacy: No network calls required for core usage. No analytics or tracking in v1.

Battery: Avoid continuous animations; only animate on interaction. No background processing.

11) UX / Visual Design Principles

Minimal, calm base UI; delight is in interaction.

Consistent spacing, large tap targets.

Habit cards feel “premium” (soft shadows, blur materials sparingly, tasteful gradients).

Animations should be consistent and not distracting.

12) Technical Approach (Best Practices)

Project configuration:
- App name: Habits
- Bundle identifier: tzcl.habits
- Minimum deployment: iOS 17.0
- Devices: iPhone only
- Orientations: Portrait only (lock rotation)
- Appearance: Light mode only (no dark mode in v1)
- Assets: SF Symbols only; no custom illustrations
- Onboarding: None; user lands on empty state directly
- Launch screen: Simple solid color matching app background (white or off-white)

Architecture:

SwiftUI + MVVM with @Observable view models for testable business logic.

Keep animation logic close to views, but state changes in view models.

Use @Observable macro for view models; SwiftData @Model for persistence.

Navigation: NavigationStack with value-based navigation (NavigationPath) for Habit Details.

Project structure:
```
Habits/
├── App/
│   └── HabitsApp.swift
├── Models/
│   ├── Habit.swift (@Model)
│   └── Completion.swift (@Model)
├── ViewModels/
│   ├── HabitListViewModel.swift
│   └── HabitDetailViewModel.swift
├── Views/
│   ├── HabitListView.swift
│   ├── HabitCardView.swift
│   ├── AddHabitSheet.swift
│   ├── HabitDetailView.swift
│   └── WeekIndicatorView.swift
├── Components/
│   ├── HapticManager.swift
│   └── AnimationConstants.swift
└── Utilities/
    └── DateHelpers.swift
```

Recompute current-week dates on `.onAppear` and when app returns to foreground (`scenePhase` changes).

Haptics: Create a `HapticManager` singleton wrapping `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`.

Prefer SF Symbols for any icons (e.g., plus.circle for add, checkmark for completion).

Testing: Unit tests for view models and date utilities; UI tests for critical flows (add habit, toggle completion).

13) Metrics (Local-only, v1)

Since no backend, keep metrics minimal:

App should “feel” fast: time to first interaction < 1s.

Qualitative: user can complete a habit in 2 taps from app open.

(Optional later) On-device analytics only, privacy-preserving.

14) Out of Scope (Explicit)

Notifications/reminders

Streaks, badges, achievements system beyond simple goal celebration

Tags, folders, scheduling by specific weekdays

Home screen widgets / watch app

Cloud sync / account system

Sharing

15) Future Enhancements (Designed-for seams)

Streaks and history calendar (easy if completions are stored by date).

Reminders / notifications.

Widgets and Apple Watch companion.

Habit categories and sorting.

Templates and suggested habits.

Cloud sync (iCloud) and multi-device.

Richer animations / themes (unlockable skins).

16) Acceptance Criteria (v1)

User can add unlimited habits with a weekly target (1–7).

Home shows habit cards with 7-day indicator for current week.

Tapping a habit toggles today and updates UI + plays a reward animation + haptic.

Long press opens a details screen where user can edit/delete.

Data persists across app relaunch.

Reduce Motion is respected (no jarring motion when enabled).

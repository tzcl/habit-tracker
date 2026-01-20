import SwiftUI

struct ColorPickerGrid: View {
    @Binding var selectedColor: HabitColor

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(HabitColor.allCases, id: \.self) { color in
                ColorOptionButton(
                    color: color,
                    isSelected: selectedColor == color
                ) {
                    selectedColor = color
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ColorOptionButton: View {
    let color: HabitColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Pastel background
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.backgroundColor)
                    .frame(height: 56)

                // Accent dot
                Circle()
                    .fill(color.color)
                    .frame(width: 24, height: 24)

                // Selection indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(color.color, lineWidth: 3)
                        .frame(height: 56)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(color.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    Form {
        Section("Color") {
            ColorPickerGrid(selectedColor: .constant(.coral))
        }
    }
}

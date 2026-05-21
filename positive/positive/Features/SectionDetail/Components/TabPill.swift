import SwiftUI

struct TabPill: View {

    let title: String
    let icon: String
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack(spacing: 6) {

                Image(systemName: icon)
                    .font(.system(size: 13))

                Text(title)
                    .font(
                        .system(
                            size: 14,
                            weight: .medium,
                            design: .rounded
                        )
                    )
            }
            .foregroundColor(
                isSelected
                ? accent
                : .white.opacity(0.35)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected
                ? accent.opacity(0.15)
                : Color.white.opacity(0.06)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected
                        ? accent.opacity(0.4)
                        : Color.clear,
                        lineWidth: 1
                    )
            )
        }
    }
}

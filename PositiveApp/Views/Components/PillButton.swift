import SwiftUI

struct PillButton: View {
    let timeOfDay: TimeOfDay
    @Binding var isOpen: Bool

    @State private var rotation: Double = 0

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
                isOpen.toggle()
                rotation += isOpen ? 45 : -45
            }
        } label: {
            ZStack {
                // Pill shape
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: timeOfDay.pillGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 44)
                    .shadow(color: timeOfDay.pillGradient.last!.opacity(0.45), radius: 12, x: 0, y: 6)

                // Icon morphs between + and ×
                Image(systemName: isOpen ? "xmark" : "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

import SwiftUI

// MARK: - Pagination Dots
struct PaginationDotsView: View {
    let current: Int
    let total: Int
    let timeOfDay: TimeOfDay

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current
                          ? timeOfDay.accentColor
                          : timeOfDay.accentColor.opacity(0.25))
                    .frame(width: i == current ? 10 : 7,
                           height: i == current ? 10 : 7)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: current)
            }
        }
    }
}

// MARK: - Swipe Hint
struct SwipeHintView: View {
    let timeOfDay: TimeOfDay
    @State private var arrowOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: 4) {
            Text("swipe for more")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(timeOfDay.accentColor.opacity(0.85))

            Text("→")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(timeOfDay.accentColor)
                .offset(x: arrowOffset)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                    ) {
                        arrowOffset = 5
                    }
                }
        }
    }
}

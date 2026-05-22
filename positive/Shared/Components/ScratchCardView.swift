import SwiftUI

struct ScratchCardView: View {
    let thought: String
    let timeOfDay: TimeOfDay
    @Binding var hasScratched: Bool

    @State private var scratchPoints: [CGPoint] = []
    @State private var isRevealed: Bool = false
    @State private var cardSize: CGSize = .zero

    private let scratchRadius: CGFloat = 28
    private let revealThreshold = 55  // number of points before auto-reveal

    var body: some View {
        ZStack {
            // ── Revealed content (always present underneath)
            VStack(spacing: 14) {
                Text("✨")
                    .font(.system(size: 36))
                Text(thought)
                    .font(.custom("Georgia", size: 19))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(timeOfDay.cardTextColor)
                    .padding(.horizontal, 8)
                    .lineSpacing(4)
            }
            .padding(28)

            // ── Foil overlay (only shown until revealed)
            if !isRevealed {
                foilOverlay
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                scratchPoints.append(value.location)
                                if scratchPoints.count >= revealThreshold {
                                    revealWithAnimation()
                                }
                            }
                    )
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(timeOfDay.cardBackground)
                .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 10)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .padding(.horizontal, 24)
        .onAppear {
            if hasScratched { isRevealed = true }
        }
    }

    // MARK: - Foil layer drawn in Canvas
    private var foilOverlay: some View {
        Canvas { context, size in
            // Silver foil base
            let foilRect = CGRect(origin: .zero, size: size)
            context.fill(
                Path(foilRect),
                with: .linearGradient(
                    Gradient(stops: [
                        .init(color: Color(hex: "D4D4D4"), location: 0.0),
                        .init(color: Color(hex: "F0F0F0"), location: 0.3),
                        .init(color: Color(hex: "B8B8B8"), location: 0.6),
                        .init(color: Color(hex: "E8E8E8"), location: 1.0)
                    ]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: size.width, y: size.height)
                )
            )

            // Shimmer lines
            for i in stride(from: 0, through: size.width + size.height, by: 14) {
                var line = Path()
                line.move(to: CGPoint(x: i, y: 0))
                line.addLine(to: CGPoint(x: 0, y: i))
                context.stroke(line, with: .color(.white.opacity(0.18)), lineWidth: 1)
            }

            // "Scratch here" hint text
            context.draw(
                Text("Scratch to reveal ✨")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "888888")),
                at: CGPoint(x: size.width / 2, y: size.height / 2)
            )

            // Erase scratched areas using destination-out blend
            context.blendMode = .destinationOut
            for point in scratchPoints {
                let circle = Path(ellipseIn: CGRect(
                    x: point.x - scratchRadius,
                    y: point.y - scratchRadius,
                    width: scratchRadius * 2,
                    height: scratchRadius * 2
                ))
                context.fill(circle, with: .color(.black))
            }
        }
        .compositingGroup()       // required for destinationOut to work
        .allowsHitTesting(true)
    }

    // MARK: - Reveal
    private func revealWithAnimation() {
        guard !isRevealed else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isRevealed = true
            hasScratched = true
        }
    }
}

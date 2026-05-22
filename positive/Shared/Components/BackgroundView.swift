import SwiftUI

struct BackgroundView: View {
    let timeOfDay: TimeOfDay
    @State private var animating = false

    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: timeOfDay.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: timeOfDay)

            // Per-time decorations
            switch timeOfDay {
            case .morning:   MorningDecoration(animating: animating)
            case .afternoon: AfternoonDecoration(animating: animating)
            case .evening:   EveningDecoration(animating: animating)
            case .night:     NightDecoration(animating: animating)
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - Morning: pulsing sun rays + soft bubbles
private struct MorningDecoration: View {
    let animating: Bool
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Sun rays
            ForEach(0..<8, id: \.self) { i in
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 4, height: pulse ? 140 : 110)
                    .offset(y: -80)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .animation(
                        .easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(Double(i) * 0.15),
                        value: pulse
                    )
            }

            // Soft pastel bubbles
            BubbleField(colors: [
                Color(hex: "FFB3BA"), Color(hex: "B8F0C8"), Color(hex: "DDB3FF")
            ], animating: animating)
        }
        .onAppear { pulse = animating }
    }
}

// MARK: - Afternoon: floating clouds
private struct AfternoonDecoration: View {
    let animating: Bool
    @State private var drift = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                CloudShape()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: CGFloat([160, 120, 100][i]),
                           height: CGFloat([70, 55, 45][i]))
                    .offset(
                        x: drift ? CGFloat([-60, 40, -20][i]) : CGFloat([-80, 20, -40][i]),
                        y: CGFloat([-180, -120, -60][i])
                    )
                    .animation(
                        .easeInOut(duration: Double([6, 8, 5][i])).repeatForever(autoreverses: true).delay(Double(i) * 0.8),
                        value: drift
                    )
            }

            BubbleField(colors: [
                Color(hex: "FFB3BA"), Color(hex: "B8F0C8"), Color(hex: "DDB3FF")
            ], animating: animating)
        }
        .onAppear { drift = animating }
    }
}

// MARK: - Evening: glowing orb + particles
private struct EveningDecoration: View {
    let animating: Bool
    @State private var glow = false
    @State private var float = false

    var body: some View {
        ZStack {
            // Glowing orb
            Circle()
                .fill(Color(hex: "FFD700").opacity(glow ? 0.25 : 0.12))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(y: float ? -60 : -80)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: glow)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: float)

            // Floating particles
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: CGFloat.random(in: 4...10))
                    .offset(
                        x: CGFloat.random(in: -160...160),
                        y: float ? CGFloat.random(in: -300...100) : CGFloat.random(in: -200...200)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.3),
                        value: float
                    )
            }
        }
        .onAppear { glow = true; float = true }
    }
}

// MARK: - Night: stars + moon + shooting star
private struct NightDecoration: View {
    let animating: Bool
    @State private var twinkle = false
    @State private var shoot = false

    var body: some View {
        ZStack {
            // Stars
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat([2, 3, 4, 2, 3][i % 5]))
                    .opacity(twinkle ? Double.random(in: 0.4...1.0) : Double.random(in: 0.2...0.7))
                    .offset(
                        x: CGFloat.random(in: -180...180),
                        y: CGFloat.random(in: -380...0)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 1.5...3.5))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.1),
                        value: twinkle
                    )
            }

            // Moon
            Circle()
                .fill(Color(hex: "FFF9C4"))
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .fill(Color(hex: "1E2F50"))
                        .frame(width: 40, height: 40)
                        .offset(x: 8, y: -4)
                )
                .offset(x: 100, y: -280)

            // Shooting star
            Capsule()
                .fill(Color.white.opacity(0.8))
                .frame(width: shoot ? 80 : 0, height: 2)
                .offset(x: shoot ? 60 : -60, y: -200)
                .rotationEffect(.degrees(-30))
                .animation(
                    .easeIn(duration: 0.6).delay(4).repeatForever(autoreverses: false),
                    value: shoot
                )
        }
        .onAppear { twinkle = true; shoot = true }
    }
}

// MARK: - Shared: pastel bubble field
private struct BubbleField: View {
    let colors: [Color]
    let animating: Bool
    @State private var float = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(colors[i % colors.count].opacity(0.35))
                    .frame(width: CGFloat([140, 110, 90][i]))
                    .offset(
                        x: CGFloat([-120, 130, -50][i]),
                        y: float
                            ? CGFloat([80, 120, 200][i])
                            : CGFloat([100, 140, 220][i])
                    )
                    .animation(
                        .easeInOut(duration: Double([5, 7, 6][i]))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.5),
                        value: float
                    )
            }
        }
        .onAppear { float = animating }
    }
}

// MARK: - Cloud shape helper
private struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: CGRect(x: rect.width * 0.1, y: rect.height * 0.3, width: rect.width * 0.5, height: rect.height * 0.7))
        p.addEllipse(in: CGRect(x: rect.width * 0.35, y: rect.height * 0.1, width: rect.width * 0.4, height: rect.height * 0.65))
        p.addEllipse(in: CGRect(x: rect.width * 0.55, y: rect.height * 0.25, width: rect.width * 0.38, height: rect.height * 0.7))
        return p
    }
}

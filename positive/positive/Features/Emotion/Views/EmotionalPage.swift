import SwiftUI

struct EmotionalPage: View {

    let title: String
    let subtitle: String
    let imageName: String

    var body: some View {

        ZStack {

            // Background image
            Image(imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Dark overlay for readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer()

                Text(title)
                    .font(
                        .system(
                            size: 34,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text(subtitle)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer()
            }
            .padding(.bottom, 120)
        }
    }
}

#Preview {
    EmotionalPage(
        title: "You did enough today.",
        subtitle: "Rest without guilt.",
        imageName: "calm"
    )
}

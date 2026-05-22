import SwiftUI

// MARK: - Reminder Card
struct ReminderCardView: View {
    let reminder: String
    let timeOfDay: TimeOfDay

    var body: some View {
        ContentCard(
            icon: "💡",
            label: "Today's Reminder",
            text: reminder,
            background: timeOfDay.reminderBackground,
            textColor: timeOfDay.cardTextColor,
            labelColor: Color(hex: "C8A020")
        )
    }
}

// MARK: - Joke Card
struct JokeCardView: View {
    let joke: String
    let timeOfDay: TimeOfDay

    var body: some View {
        ContentCard(
            icon: "😄",
            label: "A Thought For You",
            text: joke,
            background: timeOfDay.jokeBackground,
            textColor: timeOfDay.cardTextColor,
            labelColor: Color(hex: "4A9A5A")
        )
    }
}

// MARK: - Shared card layout
private struct ContentCard: View {
    let icon: String
    let label: String
    let text: String
    let background: Color
    let textColor: Color
    let labelColor: Color

    var body: some View {
        VStack(spacing: 14) {
            Text(icon)
                .font(.system(size: 36))

            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(labelColor)
                .tracking(1.2)
                .textCase(.uppercase)

            Text(text)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .lineSpacing(4)
                .padding(.horizontal, 8)
        }
        .padding(28)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(background)
                .shadow(color: .black.opacity(0.1), radius: 24, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
    }
}

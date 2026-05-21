import SwiftUI

struct GreetingView: View {
    let timeOfDay: TimeOfDay
    let isHeader: Bool      // false = centred hero, true = top header

    var body: some View {
        VStack(spacing: isHeader ? 2 : 10) {
            Text("\(timeOfDay.greeting) \(timeOfDay.emoji)")
                .font(isHeader
                      ? .system(size: 26, weight: .bold, design: .rounded)
                      : .system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(timeOfDay.headingColor)
                .kerning(isHeader ? 0.3 : 0.8)
                .multilineTextAlignment(.center)
                .shadow(color: .white.opacity(0.4), radius: 2)

            if !isHeader {
                Text(timeOfDay.subtitle)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(timeOfDay.subtitleColor)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, isHeader ? 60 : 0)           // safe area top when header
        .padding(.bottom, isHeader ? 8 : 0)
        .frame(maxWidth: .infinity,
               maxHeight: isHeader ? nil : .infinity,   // fills screen when centred
               alignment: isHeader ? .leading : .center)
    }
}

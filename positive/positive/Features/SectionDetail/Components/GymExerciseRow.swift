import SwiftUI

struct GymExerciseRow: View {

    let name: String
    let accent: Color
    let isDone: Bool
    let onTap: () -> Void

    var body: some View {

        Button(action: onTap) {

            HStack(spacing: 12) {

                ZStack {

                    Circle()
                        .fill(isDone ? accent.opacity(0.8) : .clear)
                        .frame(width: 24, height: 24)

                    Circle()
                        .strokeBorder(
                            isDone ? accent : .white.opacity(0.3),
                            lineWidth: 1.5
                        )
                        .frame(width: 24, height: 24)

                    if isDone {

                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Text(name)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(
                        isDone
                        ? .white.opacity(0.35)
                        : .white
                    )
                    .strikethrough(
                        isDone,
                        color: .white.opacity(0.35)
                    )

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(.white.opacity(0.07))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

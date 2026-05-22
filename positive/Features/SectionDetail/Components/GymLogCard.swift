import SwiftUI

struct GymLogCard: View {

    let log: GymLog
    let accent: Color

    private func timeLabel() -> String {

        let f = DateFormatter()
        f.dateFormat = "h:mm a"

        return f.string(from: log.date)
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {

                VStack(alignment: .leading, spacing: 2) {

                    Text(log.dayName)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Logged at \(timeLabel())")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(accent.opacity(0.7))
                }

                Spacer()

                Text("\(log.completedExercises.count) done")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(accent.opacity(0.15))
                    .cornerRadius(10)
            }

            if let km = log.distanceKm {

                HStack(spacing: 16) {

                    HStack(spacing: 4) {

                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(accent)

                        Text(String(format: "%.1f km", km))
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    if let min = log.durationMin {

                        HStack(spacing: 4) {

                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(accent)

                            Text("\(min) min")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }

            if !log.completedExercises.isEmpty {

                VStack(alignment: .leading, spacing: 4) {

                    ForEach(log.completedExercises, id: \.self) { ex in

                        HStack(spacing: 8) {

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(accent.opacity(0.7))

                            Text(ex)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }

            if !log.notes.isEmpty {

                Text(log.notes)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(10)
                    .background(.white.opacity(0.05))
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(.white.opacity(0.07))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(accent.opacity(0.15), lineWidth: 1)
        )
    }
}

import SwiftUI

struct GymHistoryView: View {
    @ObservedObject var store: GymStore
    let accent: Color
    let onDismiss: () -> Void

    @State private var selectedDate = Date()

    private var logsForSelected: [GymLog] {
        store.logsOnDate(selectedDate)
    }

    private func dateLabel(_ date: Date) -> String {
        let cal = Calendar.current

        if cal.isDateInToday(date) {
            return "Today"
        }

        if cal.isDateInYesterday(date) {
            return "Yesterday"
        }

        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"

        return f.string(from: date)
    }

    private var logDates: [Date] {
        var seen = Set<String>()

        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"

        return store.logs.compactMap { log -> Date? in

            let key = f.string(from: log.date)

            if seen.contains(key) {
                return nil
            }

            seen.insert(key)

            return log.date

        }
        .sorted { $0 > $1 }
    }

    var body: some View {

        ZStack {

            Color(red: 0.08, green: 0.06, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                HStack {

                    Button(action: onDismiss) {

                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Workout History")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Circle()
                        .fill(.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)

                if store.logs.isEmpty {

                    Spacer()

                    VStack(spacing: 12) {

                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 44, weight: .light))
                            .foregroundColor(.white.opacity(0.15))

                        Text("No sessions logged yet")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))

                        Text("Complete a workout and tap Save Session")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.white.opacity(0.2))
                    }

                    Spacer()

                } else {

                    ScrollView(.horizontal, showsIndicators: false) {

                        HStack(spacing: 8) {

                            ForEach(logDates, id: \.self) { date in

                                let isSelected = Calendar.current.isDate(
                                    date,
                                    inSameDayAs: selectedDate
                                )

                                Button {
                                    selectedDate = date
                                } label: {

                                    Text(dateLabel(date))
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(
                                            isSelected
                                            ? .white
                                            : .white.opacity(0.4)
                                        )
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            isSelected
                                            ? accent.opacity(0.8)
                                            : .white.opacity(0.07)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 16)

                    if logsForSelected.isEmpty {

                        VStack(spacing: 8) {

                            Spacer()

                            Text("No sessions on this date")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white.opacity(0.3))

                            Spacer()
                        }

                    } else {

                        ScrollView {

                            VStack(spacing: 14) {

                                ForEach(logsForSelected) { log in
                                    GymLogCard(
                                        log: log,
                                        accent: accent
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
        }
    }
}

import SwiftUI

struct SpiritualitySectionView: View {

    let sectionColor: String
    var onDismiss: () -> Void

    var accent: Color {
        Color(hex: sectionColor)
    }

    @State private var prayers: [PrayerCard] = [
        PrayerCard(
            name: "Hanuman Chalisa",
            subtitle: "",
            frequency: "1× daily",
            time: nil,
            icon: "hands.sparkles"
        ),

        PrayerCard(
            name: "Morning prayer",
            subtitle: "",
            frequency: "",
            time: "7 AM",
            icon: "sun.horizon"
        ),

        PrayerCard(
            name: "Meditation",
            subtitle: "",
            frequency: "2× daily",
            time: "10 min",
            icon: "brain.head.profile"
        )
    ]

    @State private var showAdd = false

    var body: some View {

        ZStack {

            Color(red: 0.07, green: 0.09, blue: 0.15)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                SectionHeader(
                    icon: "sparkles",
                    title: "Spirituality",
                    accentColor: accent,

                    trailing: AnyView(

                        Button {

                            withAnimation(.spring()) {
                                showAdd.toggle()
                            }

                        } label: {

                            Image(systemName: showAdd ? "xmark" : "plus")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(12)
                                .background(.white.opacity(0.08))
                                .clipShape(Circle())
                        }
                    ),

                    onDismiss: onDismiss
                )

                if showAdd {

                    AddPrayerView(
                        accent: accent
                    ) { prayer in

                        withAnimation {

                            prayers.append(prayer)
                            showAdd = false
                        }
                    }
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                    )
                }

                ScrollView {
                    if prayers.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.6))
                                .accessibilityHidden(true)

                            Text("No prayers added yet. Tap '+' to add one.")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50)
                    } else {
                        LazyVStack(spacing: 12) {

                            ForEach($prayers) { $prayer in

                                PrayerCardRow(
                                    prayer: $prayer,
                                    accent: accent
                                ) {

                                    withAnimation {

                                        prayers.removeAll {
                                            $0.id == prayer.id
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}

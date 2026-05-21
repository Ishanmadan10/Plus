import SwiftUI

struct GymDayManagerView: View {

    @ObservedObject var store: GymStore
    let accent: Color
    let onDismiss: () -> Void

    @State private var showAddDay = false
    @State private var newDayName = ""

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

                    Text("Manage Days")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        showAddDay = true
                    } label: {

                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(12)
                            .background(.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 8)

                Text("Swipe to delete · Drag ≡ to reorder")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.25))
                    .padding(.bottom, 12)

                List {

                    ForEach(store.days) { day in

                        HStack {

                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.3))

                            Text(day.name)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white)

                            Spacer()

                            Text("\(day.exercises.count) exercises")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .listRowBackground(Color.white.opacity(0.07))
                        .listRowSeparatorTint(.white.opacity(0.08))
                    }
                    .onDelete { offsets in
                        store.deleteDay(at: offsets)
                    }
                    .onMove { from, to in
                        store.days.move(fromOffsets: from, toOffset: to)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, .constant(.active))
            }

            if showAddDay {

                QuickInputOverlay(
                    title: "New Day",
                    placeholder: "e.g. Cycling, Shoulders…",
                    accent: accent,
                    value: $newDayName,
                    onSave: {

                        let name = newDayName
                            .trimmingCharacters(in: .whitespaces)

                        guard !name.isEmpty else { return }

                        store.addDay(name: name)

                        newDayName = ""
                        showAddDay = false
                    },
                    onCancel: {
                        showAddDay = false
                        newDayName = ""
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .zIndex(10)
            }
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.85),
            value: showAddDay
        )
    }
}

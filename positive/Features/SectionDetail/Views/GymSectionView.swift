import SwiftUI

struct GymSectionView: View {
    let sectionColor: String
    var onDismiss: () -> Void

    @StateObject private var store = GymStore()
    @State private var selectedDayID: UUID? = nil
    @State private var completed: Set<UUID> = []
    @State private var notes = ""
    @State private var distanceKm = ""
    @State private var durationMin = ""
    @State private var showAddDay = false
    @State private var newDayName = ""
    @State private var showAddExercise = false
    @State private var newExerciseName = ""
    @State private var showHistory = false
    @State private var showDayManager = false
    @FocusState private var notesFocused: Bool

    var accent: Color { Color(hex: sectionColor) }

    var selectedDay: GymDay? {
        store.days.first(where: { $0.id == selectedDayID })
    }

    private var todayLogExists: Bool {
        guard let day = selectedDay else { return false }

        let cal = Calendar.current

        return store.logs.contains {
            cal.isDateInToday($0.date) &&
            $0.dayName == day.name
        }
    }

    private var isCardiDay: Bool {
        guard let day = selectedDay else { return false }

        let cardioKeywords = [
            "cycling",
            "cycle",
            "running",
            "run",
            "walk",
            "cardio",
            "swim"
        ]

        return cardioKeywords.contains {
            day.name.lowercased().contains($0)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.06, blue: 0.06)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                SectionHeader(
                    icon: "figure.run",
                    title: "Gym",
                    accentColor: accent,
                    trailing: AnyView(
                        HStack(spacing: 8) {

                            Button {
                                showHistory = true
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(10)
                                    .background(.white.opacity(0.08))
                                    .clipShape(Circle())
                            }

                            Button {
                                showDayManager = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(10)
                                    .background(.white.opacity(0.08))
                                    .clipShape(Circle())
                            }
                        }
                    ),
                    onDismiss: onDismiss
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {

                        ForEach(store.days) { day in
                            Button {

                                withAnimation(.spring()) {

                                    selectedDayID = day.id
                                    restoreSessionIfNeeded()
                                }

                            } label: {

                                Text(day.name)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(
                                        selectedDayID == day.id
                                        ? .white
                                        : .white.opacity(0.4)
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedDayID == day.id
                                        ? accent.opacity(0.85)
                                        : Color.white.opacity(0.07)
                                    )
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                selectedDayID == day.id
                                                ? accent
                                                : .white.opacity(0.1),
                                                lineWidth: 1
                                            )
                                    )
                            }
                        }

                        Button {
                            showAddDay = true
                        } label: {

                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)

                if let day = selectedDay {

                    ScrollView {

                        LazyVStack(spacing: 10) {

                            if isCardiDay {

                                HStack(spacing: 12) {

                                    VStack(alignment: .leading, spacing: 4) {

                                        Text("Distance (km)")
                                            .font(.system(size: 11, design: .rounded))
                                            .foregroundColor(.white.opacity(0.4))

                                        TextField("e.g. 15", text: $distanceKm)
                                            .keyboardType(.decimalPad)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(.white.opacity(0.08))
                                            .cornerRadius(12)
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, design: .rounded))
                                    }

                                    VStack(alignment: .leading, spacing: 4) {

                                        Text("Duration (min)")
                                            .font(.system(size: 11, design: .rounded))
                                            .foregroundColor(.white.opacity(0.4))

                                        TextField("e.g. 45", text: $durationMin)
                                            .keyboardType(.numberPad)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(.white.opacity(0.08))
                                            .cornerRadius(12)
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, design: .rounded))
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            ForEach(day.exercises) { ex in

                                GymExerciseRow(
                                    name: ex.name,
                                    accent: accent,
                                    isDone: completed.contains(ex.id)
                                ) {

                                    withAnimation(.spring()) {

                                        if completed.contains(ex.id) {
                                            completed.remove(ex.id)
                                        } else {
                                            completed.insert(ex.id)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            Button {

                                showAddExercise = true

                            } label: {

                                HStack(spacing: 8) {

                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 14))

                                    Text("Add exercise")
                                        .font(.system(size: 14, design: .rounded))
                                }
                                .foregroundColor(accent.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(accent.opacity(0.08))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(accent.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 20)

                            ZStack(alignment: .topLeading) {

                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.white.opacity(0.1), lineWidth: 1)
                                    )

                                TextEditor(text: $notes)
                                    .scrollContentBackground(.hidden)
                                    .background(.clear)
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.system(size: 14, design: .rounded))
                                    .padding(12)
                                    .focused($notesFocused)
                                    .frame(minHeight: 80)

                                if notes.isEmpty {

                                    Text("Session notes...")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.white.opacity(0.2))
                                        .padding(16)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                            Button {
                                saveSession()
                            } label: {

                                HStack(spacing: 8) {

                                    Image(systemName:
                                            todayLogExists
                                          ? "checkmark.circle.fill"
                                          : "square.and.arrow.down"
                                    )
                                    .font(.system(size: 15))

                                    Text(
                                        todayLogExists
                                        ? "Update Today's Session"
                                        : "Save Session"
                                    )
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(accent.opacity(0.85))
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }

                } else {

                    Spacer()

                    VStack(spacing: 12) {

                        Image(systemName: "dumbbell")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.white.opacity(0.15))

                        Text("Select a workout day above")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                    }

                    Spacer()
                }
            }

            if showAddDay {

                QuickInputOverlay(
                    title: "New Day",
                    placeholder: "e.g. Cycling, Shoulders…",
                    accent: accent,
                    value: $newDayName,
                    onSave: {

                        let name = newDayName.trimmingCharacters(in: .whitespaces)

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
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(20)
            }

            if showAddExercise,
               let dayID = selectedDayID {

                QuickInputOverlay(
                    title: "New Exercise",
                    placeholder: "e.g. Incline press 3×12",
                    accent: accent,
                    value: $newExerciseName,
                    onSave: {

                        let name = newExerciseName.trimmingCharacters(in: .whitespaces)

                        guard !name.isEmpty else { return }

                        store.addExercise(name, toDayWithID: dayID)

                        newExerciseName = ""
                        showAddExercise = false
                    },
                    onCancel: {
                        showAddExercise = false
                        newExerciseName = ""
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(20)
            }

            if showHistory {

                GymHistoryView(
                    store: store,
                    accent: accent
                ) {
                    showHistory = false
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(20)
            }

            if showDayManager {

                GymDayManagerView(
                    store: store,
                    accent: accent
                ) {
                    showDayManager = false
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(20)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showAddDay)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showAddExercise)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showHistory)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showDayManager)

        // Change onAppear to this:
        .onAppear {
            if selectedDayID == nil, let first = store.days.first {
                selectedDayID = first.id
            }
            // Restore today's selections for whatever day is selected
            restoreSessionIfNeeded()
        }

        .onTapGesture {
            notesFocused = false
        }
    }

    private func saveSession() {

        guard let day = selectedDay else { return }

        let completedNames = day.exercises
            .filter { completed.contains($0.id) }
            .map { $0.name }

        let log = GymLog(
            date: Date(),
            dayName: day.name,
            completedExercises: completedNames,
            notes: notes.trimmingCharacters(in: .whitespaces),
            distanceKm: Double(distanceKm),
            durationMin: Int(durationMin)
        )

        store.saveLog(log)

        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
    }

// Add this private function alongside saveSession():
private func restoreSessionIfNeeded() {
    guard let day = selectedDay else { return }
    
    // Only restore if there's a log from today
    guard let log = store.logs.first(where: {
        Calendar.current.isDateInToday($0.date) &&
        $0.dayName == day.name
    }) else {
        // If no log exists for today, clear the current state to reflect an empty session
        completed = []
        notes = ""
        distanceKm = ""
        durationMin = ""
        return
    }
    
    // Restore completed exercises from today's log
    completed = Set(
        day.exercises
            .filter { log.completedExercises.contains($0.name) }
            .map { $0.id }
    )
    
    notes = log.notes
    
    if let km = log.distanceKm {
        distanceKm = String(format: "%.1f", km)
    } else {
        distanceKm = ""
    }
    
    if let min = log.durationMin {
        durationMin = "\(min)"
    } else {
        durationMin = ""
    }
}
}

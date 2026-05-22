import SwiftUI

struct HabitChecklistView: View {

    @ObservedObject var store: HabitStore
    var onDismiss: () -> Void

    @State private var newHabit = ""
    @State private var showAddField = false
    @FocusState private var fieldFocused: Bool      // ✅ track keyboard

    var body: some View {

        ZStack {
            Rectangle()
                .fill(.black.opacity(0.75))
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Header
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(.white.opacity(0.15))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Today")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showAddField.toggle()
                            if !showAddField { fieldFocused = false }
                        }
                    } label: {
                        Image(systemName: showAddField ? "xmark" : "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 16)

                // MARK: - Add field
                if showAddField {
                    HStack(spacing: 12) {
                        TextField("New habit...", text: $newHabit)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.1))
                            .cornerRadius(16)
                            .foregroundColor(.white)
                            .font(.system(size: 15, design: .rounded))
                            .focused($fieldFocused)         // ✅
                            .onSubmit { addHabit() }

                        Button(action: addHabit) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        .disabled(newHabit.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear { fieldFocused = true }       // ✅ auto focus
                }

                // MARK: - Hint
                Text("Swipe left to delete")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 8)

                // MARK: - Habit list
                ScrollView {
                    if store.habits.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.2))
                                .accessibilityHidden(true)

                            Text("No habits yet! Tap '+' to add your first habit.")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(store.habits) { habit in
                                HabitRow(habit: habit,
                                    onTap: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            store.toggle(habit)
                                        }
                                    },
                                    onDelete: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            store.delete(habit)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                }
                // ✅ lets scroll happen even when finger starts on a row
                .simultaneousGesture(DragGesture().onChanged { _ in
                    fieldFocused = false
                })

                // MARK: - Calendar — hidden when keyboard is up ✅
                if !fieldFocused {
                    CalendarStrip(store: store)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 36)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: fieldFocused)
        }
        // ✅ dismiss keyboard on tap outside
        .onTapGesture { fieldFocused = false }
    }

    private func addHabit() {
        store.add(title: newHabit)
        newHabit = ""
        showAddField = false
        fieldFocused = false
    }
}

// MARK: - Habit Row
private struct HabitRow: View {

    let habit: Habit
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showDelete = false

    var body: some View {
        ZStack(alignment: .trailing) {

            // Delete button
            Button(action: onDelete) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.red.opacity(0.75))
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(width: 72)
            }
            .opacity(showDelete ? 1 : 0)

            // Main row
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(habit.isCompletedToday ? Color.green.opacity(0.85) : Color.clear)
                        .frame(width: 26, height: 26)

                    Circle()
                        .strokeBorder(
                            habit.isCompletedToday ? Color.green : Color.white.opacity(0.35),
                            lineWidth: 1.5
                        )
                        .frame(width: 26, height: 26)

                    if habit.isCompletedToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Text(habit.title)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(habit.isCompletedToday ? .white.opacity(0.4) : .white)
                    .strikethrough(habit.isCompletedToday, color: .white.opacity(0.4))

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.08))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .offset(x: offset)
            // ✅ highPriorityGesture so swipe beats scroll only when clearly horizontal
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                        if isHorizontal && value.translation.width < 0 {
                            offset = max(value.translation.width, -80)
                        }
                    }
                    .onEnded { value in
                        let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if isHorizontal && value.translation.width < -50 {
                                offset = -80
                                showDelete = true
                            } else {
                                offset = 0
                                showDelete = false
                            }
                        }
                    }
            )
            .onTapGesture {
                if showDelete {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = 0
                        showDelete = false
                    }
                } else {
                    onTap()
                }
            }
            .accessibilityAction(named: "Delete") {
                onDelete()
            }
        }
    }
}

// MARK: - Calendar Strip
private struct CalendarStrip: View {

    @ObservedObject var store: HabitStore

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(spacing: 12) {

            Text(monthLabel)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .tracking(3)
                .foregroundColor(.white.opacity(0.4))

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(dayLabels, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    DayCell(
                        date: date,
                        ratio: date != nil ? store.completionRatio(for: dateKey(date!)) : 0,
                        isToday: date != nil && calendar.isDateInToday(date!),
                        isFuture: date != nil && date! > Date()
                    )
                }
            }

            HStack(spacing: 16) {
                LegendDot(color: .green, label: "all done")
                LegendDot(color: .white.opacity(0.35), label: "partial")
                LegendDot(color: .white.opacity(0.1), label: "missed")
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(.white.opacity(0.06))
        .cornerRadius(20)
    }

    private var monthLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: Date()).uppercased()
    }

    private func dateKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func daysInMonth() -> [Date?] {
        let now = Date()
        let comps = calendar.dateComponents([.year, .month], from: now)
        guard let firstOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }

        var weekday = calendar.component(.weekday, from: firstOfMonth) - 2
        if weekday < 0 { weekday = 6 }

        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }
}

private struct DayCell: View {

    let date: Date?
    let ratio: Double
    let isToday: Bool
    let isFuture: Bool

    private var fill: Color {
        guard date != nil, !isFuture else { return .clear }
        if ratio >= 1.0 { return .green.opacity(0.85) }
        if ratio > 0    { return .white.opacity(0.25) }
        return .white.opacity(0.08)
    }

    private var dayNumber: String {
        guard let date else { return "" }
        return "\(Calendar.current.component(.day, from: date))"
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(fill)
                .frame(height: 32)

            if isToday {
                Circle()
                    .strokeBorder(.white, lineWidth: 2)
                    .frame(height: 32)
            }

            if date != nil {
                Text(dayNumber)
                    .font(.system(size: 10, weight: isToday ? .bold : .regular, design: .rounded))
                    .foregroundColor(isFuture ? .white.opacity(0.2) : .white.opacity(ratio >= 1 ? 1 : 0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 36)
    }
}

private struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
        }
    }
}

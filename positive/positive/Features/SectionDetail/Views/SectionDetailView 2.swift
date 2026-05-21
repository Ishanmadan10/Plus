//import SwiftUI
//import PhotosUI
//import UIKit
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - SectionDetailView (router)
//// ─────────────────────────────────────────────────────────────
//struct SectionDetailView: View {
//
//    let sectionName: String
//    let sectionIcon: String
//    let sectionColor: String
//    @Binding var tasks: [String]
//    @ObservedObject var noteStore: NoteStore
//    var onDismiss: () -> Void
//
//    var body: some View {
//        switch sectionName {
//        case "Work":
//            WorkSectionView(sectionColor: sectionColor,
//                            tasks: $tasks,
//                            noteStore: noteStore,
//                            onDismiss: onDismiss)
//        case "Groceries":
//            GroceriesSectionView(sectionColor: sectionColor,
//                                 onDismiss: onDismiss)
//        case "Gym":
//            GymSectionView(sectionColor: sectionColor,
//                           onDismiss: onDismiss)
//        case "Journal":
//            JournalSectionView(sectionColor: sectionColor,
//                               noteStore: noteStore,
//                               onDismiss: onDismiss)
//        case "Spirituality":
//            SpiritualitySectionView(sectionColor: sectionColor,
//                                    onDismiss: onDismiss)
//        default:
//            GenericSectionView(sectionName: sectionName,
//                               sectionIcon: sectionIcon,
//                               sectionColor: sectionColor,
//                               tasks: $tasks,
//                               noteStore: noteStore,
//                               onDismiss: onDismiss)
//        }
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - Shared header helper
//// ─────────────────────────────────────────────────────────────
//private struct SectionHeader: View {
//    let icon: String
//    let title: String
//    let accentColor: Color
//    var trailing: AnyView? = nil
//    let onDismiss: () -> Void
//
//    var body: some View {
//        HStack {
//            Button(action: onDismiss) {
//                Image(systemName: "chevron.down")
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(.white.opacity(0.8))
//                    .padding(12)
//                    .background(.white.opacity(0.1))
//                    .clipShape(Circle())
//            }
//            Spacer()
//            HStack(spacing: 8) {
//                Image(systemName: icon)
//                    .font(.system(size: 16))
//                    .foregroundColor(accentColor)
//                Text(title)
//                    .font(.system(size: 24, weight: .semibold, design: .rounded))
//                    .foregroundColor(.white)
//            }
//            Spacer()
//            if let t = trailing {
//                t
//            } else {
//                Circle().fill(.clear).frame(width: 44, height: 44)
//            }
//        }
//        .padding(.horizontal, 20)
//        .padding(.top, 60)
//        .padding(.bottom, 16)
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - Tab Pill
//// ─────────────────────────────────────────────────────────────
//private struct TabPill: View {
//    let title: String
//    let icon: String
//    let isSelected: Bool
//    let accent: Color
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 6) {
//                Image(systemName: icon).font(.system(size: 13))
//                Text(title).font(.system(size: 14, weight: .medium, design: .rounded))
//            }
//            .foregroundColor(isSelected ? accent : .white.opacity(0.35))
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 10)
//            .background(isSelected ? accent.opacity(0.15) : Color.white.opacity(0.06))
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(isSelected ? accent.opacity(0.4) : Color.clear, lineWidth: 1)
//            )
//        }
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - 1. WORK SECTION
//// ─────────────────────────────────────────────────────────────
//struct WorkSectionView: View {
//    let sectionColor: String
//    @Binding var tasks: [String]
//    @ObservedObject var noteStore: NoteStore
//    var onDismiss: () -> Void
//
//    enum Tab { case checklist, notes }
//    @State private var tab: Tab = .checklist
//    @State private var newTask = ""
//    @State private var showDatePicker = false
//    @State private var reminderDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
//    @State private var showNoteEditor = false
//    @State private var showNotesList = false
//    @State private var editingNote: Note? = nil
//
//    var accent: Color { Color(hex: sectionColor) }
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.08, green: 0.08, blue: 0.14).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                SectionHeader(icon: "briefcase", title: "Work", accentColor: accent, onDismiss: onDismiss)
//
//                HStack(spacing: 8) {
//                    TabPill(title: "Checklist", icon: "checklist", isSelected: tab == .checklist, accent: accent) { tab = .checklist }
//                    TabPill(title: "Notes", icon: "note.text", isSelected: tab == .notes, accent: accent) { tab = .notes }
//                }
//                .padding(.horizontal, 20)
//                .padding(.bottom, 14)
//
//                if tab == .checklist { workChecklist } else { workNotes }
//            }
//
//            if showNoteEditor {
//                NoteEditorView(sectionName: "Work", accentColor: accent, noteStore: noteStore, existingNote: editingNote, onDismiss: { showNoteEditor = false; editingNote = nil })
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                    .zIndex(10)
//            }
//            if showNotesList {
//                NotesListView(sectionName: "Work", accentColor: accent, noteStore: noteStore,
//                              onSelect: { n in editingNote = n; showNotesList = false; showNoteEditor = true },
//                              onDismiss: { showNotesList = false })
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                    .zIndex(10)
//            }
//        }
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showNoteEditor)
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showNotesList)
//    }
//
//    private var workChecklist: some View {
//        VStack(spacing: 0) {
//            Text("Swipe left to delete")
//                .font(.system(size: 11, design: .rounded))
//                .foregroundColor(.white.opacity(0.25))
//                .padding(.bottom, 10)
//
//            TaskListView(tasks: $tasks)
//
//            if showDatePicker {
//                HStack {
//                    Image(systemName: "bell.fill").font(.system(size: 13)).foregroundColor(accent)
//                    Text("Remind me at").font(.system(size: 13, design: .rounded)).foregroundColor(.white.opacity(0.7))
//                    Spacer()
//                    Button { withAnimation { showDatePicker = false } } label: {
//                        Image(systemName: "xmark").font(.system(size: 13)).foregroundColor(.white.opacity(0.4))
//                    }
//                }
//                .padding(.horizontal, 20).padding(.top, 10)
//
//                DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
//                    .datePickerStyle(.compact).colorScheme(.dark).labelsHidden()
//                    .padding(.horizontal, 20)
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//            }
//
//            HStack(spacing: 10) {
//                TextField("Add a task...", text: $newTask)
//                    .padding(.horizontal, 16).padding(.vertical, 14)
//                    .background(.white.opacity(0.08))
//                    .cornerRadius(18)
//                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.12), lineWidth: 1))
//                    .foregroundColor(.white)
//                    .font(.system(size: 16, design: .rounded))
//                    .onSubmit { addTask() }
//
//                Button { withAnimation(.spring()) { showDatePicker.toggle() } } label: {
//                    Image(systemName: showDatePicker ? "bell.fill" : "bell")
//                        .font(.system(size: 20))
//                        .foregroundColor(showDatePicker ? accent : .white.opacity(0.4))
//                }
//
//                Button(action: addTask) {
//                    Image(systemName: "plus.circle.fill").font(.system(size: 36)).foregroundColor(accent)
//                }
//                .disabled(newTask.trimmingCharacters(in: .whitespaces).isEmpty)
//            }
//            .padding(.horizontal, 20).padding(.vertical, 16)
//            .background(.white.opacity(0.03))
//        }
//    }
//
//    private var workNotes: some View {
//        VStack(spacing: 12) {
//            HStack(spacing: 10) {
//                Button { editingNote = nil; showNoteEditor = true } label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "square.and.pencil").font(.system(size: 14))
//                        Text("New note").font(.system(size: 14, weight: .medium, design: .rounded))
//                    }
//                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 12)
//                    .background(accent.opacity(0.3)).cornerRadius(14)
//                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(accent.opacity(0.5), lineWidth: 1))
//                }
//                Button { showNotesList = true } label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "list.bullet").font(.system(size: 14))
//                        Text("All notes").font(.system(size: 14, weight: .medium, design: .rounded))
//                    }
//                    .foregroundColor(.white.opacity(0.7)).frame(maxWidth: .infinity).padding(.vertical, 12)
//                    .background(.white.opacity(0.08)).cornerRadius(14)
//                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.12), lineWidth: 1))
//                }
//            }
//            .padding(.horizontal, 20)
//
//            ZStack(alignment: .topLeading) {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color(red: 0.1, green: 0.1, blue: 0.17))
//                    .overlay(
//                        VStack(spacing: 0) {
//                            ForEach(0..<12, id: \.self) { _ in
//                                VStack(spacing: 0) {
//                                    Spacer()
//                                    Rectangle().fill(.white.opacity(0.05)).frame(height: 0.5)
//                                }.frame(height: 28)
//                            }
//                        }.padding(.horizontal, 16).padding(.top, 12)
//                    )
//
//                let recent = noteStore.notes(for: "Work")
//                if recent.isEmpty {
//                    Text("Start typing...")
//                        .font(.system(size: 15, design: .rounded))
//                        .foregroundColor(.white.opacity(0.18))
//                        .padding(20)
//                } else {
//                    VStack(alignment: .leading, spacing: 16) {
//                        ForEach(recent.prefix(3)) { note in
//                            Button { editingNote = note; showNoteEditor = true } label: {
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(note.title.isEmpty ? "Untitled" : note.title)
//                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
//                                        .foregroundColor(.white)
//                                    Text(note.content).font(.system(size: 12, design: .rounded))
//                                        .foregroundColor(.white.opacity(0.45)).lineLimit(2)
//                                }
//                            }
//                        }
//                    }
//                    .padding(20)
//                }
//            }
//            .frame(maxWidth: .infinity).frame(height: 340)
//            .padding(.horizontal, 20)
//
//            Spacer()
//        }
//    }
//
//    private func addTask() {
//        let t = newTask.trimmingCharacters(in: .whitespaces)
//        guard !t.isEmpty else { return }
//        withAnimation { tasks.insert(t, at: 0) }
//        if showDatePicker {
//            NotificationManager.shared.scheduleTaskReminder(task: t, at: reminderDate, section: "Work")
//            showDatePicker = false
//        }
//        newTask = ""
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - 2. GROCERIES SECTION  (single-select radio style)
//// ─────────────────────────────────────────────────────────────
//struct GroceryItem: Identifiable {
//    let id = UUID()
//    var name: String
//}
//
//struct GroceriesSectionView: View {
//    let sectionColor: String
//    var onDismiss: () -> Void
//
//    @State private var items: [GroceryItem] = [
//        GroceryItem(name: "Milk x2"),
//        GroceryItem(name: "Bananas"),
//        GroceryItem(name: "Protein powder"),
//        GroceryItem(name: "Eggs x12"),
//    ]
//    @State private var newItem = ""
//    // Single-select: only one item active at a time
//    @State private var selectedItemID: UUID? = nil
//
//    var accent: Color { Color(hex: sectionColor) }
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.07, green: 0.12, blue: 0.10).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                SectionHeader(
//                    icon: "cart",
//                    title: "Groceries",
//                    accentColor: accent,
//                    trailing: AnyView(
//                        Button {
//                            withAnimation { items.removeAll(); selectedItemID = nil }
//                        } label: {
//                            Image(systemName: "trash")
//                                .font(.system(size: 15))
//                                .foregroundColor(.white.opacity(0.4))
//                                .padding(12)
//                                .background(.white.opacity(0.08))
//                                .clipShape(Circle())
//                        }
//                    ),
//                    onDismiss: onDismiss
//                )
//
//                Text("Tap to select · Swipe left to delete")
//                    .font(.system(size: 11, design: .rounded))
//                    .foregroundColor(.white.opacity(0.25))
//                    .padding(.bottom, 10)
//
//                ScrollView {
//                    LazyVStack(spacing: 10) {
//                        ForEach($items) { $item in
//                            GroceryRow(
//                                item: $item,
//                                accent: accent,
//                                isSelected: selectedItemID == item.id,
//                                onSelect: {
//                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
//                                        // Toggle: tap same → deselect; tap different → switch
//                                        selectedItemID = (selectedItemID == item.id) ? nil : item.id
//                                    }
//                                },
//                                onDelete: {
//                                    withAnimation {
//                                        if selectedItemID == item.id { selectedItemID = nil }
//                                        items.removeAll { $0.id == item.id }
//                                    }
//                                }
//                            )
//                            .padding(.horizontal, 20)
//                        }
//                    }
//                    .padding(.bottom, 12)
//                }
//
//                // Order buttons
//                HStack(spacing: 10) {
//                    Button {
//                        openBlinkit()
//                    } label: {
//                        HStack(spacing: 8) {
//                            Image(systemName: "cart.fill").font(.system(size: 14))
//                            Text("Open Blinkit").font(.system(size: 13, weight: .semibold, design: .rounded))
//                        }
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 13)
//                        .background(selectedItemID != nil ? Color(hex: "F8CB2E").opacity(0.9) : Color(hex: "F8CB2E").opacity(0.35))
//                        .cornerRadius(16)
//                    }
//                    .disabled(selectedItemID == nil)
//
//                    Button {
//                        openApp(scheme: "zepto://", fallback: "https://www.zeptonow.com")
//                    } label: {
//                        HStack(spacing: 8) {
//                            Image(systemName: "bolt.fill").font(.system(size: 14))
//                            Text("Open Zepto").font(.system(size: 13, weight: .semibold, design: .rounded))
//                        }
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 13)
//                        .background(Color(hex: "8B2FC9").opacity(0.9))
//                        .cornerRadius(16)
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.bottom, 4)
//
//                // Selection hint
//                if let id = selectedItemID, let item = items.first(where: { $0.id == id }) {
//                    Text("Blinkit will search: \"\(item.name)\"")
//                        .font(.system(size: 10, design: .rounded))
//                        .foregroundColor(accent.opacity(0.8))
//                        .padding(.bottom, 4)
//                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
//                } else {
//                    Text("Tap an item to select it for Blinkit search")
//                        .font(.system(size: 10, design: .rounded))
//                        .foregroundColor(.white.opacity(0.3))
//                        .padding(.bottom, 4)
//                }
//
//                // Add row
//                HStack(spacing: 10) {
//                    TextField("Add item...", text: $newItem)
//                        .padding(.horizontal, 16).padding(.vertical, 14)
//                        .background(.white.opacity(0.07))
//                        .cornerRadius(16)
//                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.1), lineWidth: 1))
//                        .foregroundColor(.white)
//                        .font(.system(size: 15, design: .rounded))
//                        .onSubmit { addItem() }
//
//                    Button(action: addItem) {
//                        Image(systemName: "plus.circle.fill").font(.system(size: 34)).foregroundColor(accent)
//                    }
//                    .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
//                }
//                .padding(.horizontal, 20).padding(.bottom, 16)
//            }
//        }
//        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedItemID)
//    }
//
//    private func addItem() {
//        let t = newItem.trimmingCharacters(in: .whitespaces)
//        guard !t.isEmpty else { return }
//        withAnimation { items.insert(GroceryItem(name: t), at: 0) }
//        newItem = ""
//    }
//
//    private func openBlinkit() {
//        guard let id = selectedItemID, let item = items.first(where: { $0.id == id }) else { return }
//        // Strip quantity suffix like "x2", "x12"
//        let query = item.name
//            .replacingOccurrences(of: #"\s*x\d+"#, with: "", options: .regularExpression)
//            .trimmingCharacters(in: .whitespaces)
//        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        if let url = URL(string: "https://blinkit.com/s/?q=\(encoded)") {
//            UIApplication.shared.open(url)
//        }
//    }
//
//    private func openApp(scheme: String, fallback: String) {
//        if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        } else if let url = URL(string: fallback) {
//            UIApplication.shared.open(url)
//        }
//    }
//}
//
//private struct GroceryRow: View {
//    @Binding var item: GroceryItem
//    let accent: Color
//    let isSelected: Bool
//    let onSelect: () -> Void
//    let onDelete: () -> Void
//
//    @State private var offset: CGFloat = 0
//    @State private var showDelete = false
//
//    var body: some View {
//        ZStack(alignment: .trailing) {
//            Button(action: onDelete) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 16).fill(Color.red.opacity(0.75))
//                    Image(systemName: "trash").font(.system(size: 15, weight: .medium)).foregroundColor(.white)
//                }
//                .frame(width: 66)
//            }
//            .opacity(showDelete ? 1 : 0)
//
//            HStack(spacing: 12) {
//                // Radio circle — only one active
//                Button {
//                    if !showDelete { onSelect() }
//                } label: {
//                    ZStack {
//                        Circle()
//                            .fill(isSelected ? accent.opacity(0.85) : .clear)
//                            .frame(width: 24, height: 24)
//                        Circle()
//                            .strokeBorder(isSelected ? accent : .white.opacity(0.3), lineWidth: 1.5)
//                            .frame(width: 24, height: 24)
//                        // Radio inner dot (not a checkmark — signals single-select)
//                        if isSelected {
//                            Circle()
//                                .fill(Color.white)
//                                .frame(width: 8, height: 8)
//                        }
//                    }
//                }
//
//                Text(item.name)
//                    .font(.system(size: 15, design: .rounded))
//                    .foregroundColor(isSelected ? accent : .white)
//                    .fontWeight(isSelected ? .semibold : .regular)
//
//                Spacer()
//
//                if isSelected {
//                    Image(systemName: "arrow.up.right.circle.fill")
//                        .font(.system(size: 18))
//                        .foregroundColor(accent.opacity(0.7))
//                        .transition(.scale.combined(with: .opacity))
//                }
//            }
//            .padding(.horizontal, 14).padding(.vertical, 14)
//            .background(isSelected ? accent.opacity(0.1) : .white.opacity(0.07))
//            .cornerRadius(16)
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(isSelected ? accent.opacity(0.5) : .white.opacity(0.1), lineWidth: 1)
//            )
//            .offset(x: offset)
//            .gesture(
//                DragGesture()
//                    .onChanged { v in if v.translation.width < 0 { offset = max(v.translation.width, -76) } }
//                    .onEnded { v in
//                        withAnimation(.spring()) {
//                            if v.translation.width < -46 { offset = -76; showDelete = true }
//                            else { offset = 0; showDelete = false }
//                        }
//                    }
//            )
//            .onTapGesture {
//                if showDelete { withAnimation { offset = 0; showDelete = false } }
//                else { onSelect() }
//            }
//        }
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - 3. GYM SECTION  (custom days · custom exercises · history)
//// ─────────────────────────────────────────────────────────────
//
//// MARK: Data models
//
//struct GymDay: Identifiable, Codable, Equatable {
//    var id = UUID()
//    var name: String
//    var exercises: [GymExercise]
//}
//
//struct GymExercise: Identifiable, Codable, Equatable {
//    var id = UUID()
//    var name: String
//}
//
///// One dated log entry for a day
//struct GymLog: Identifiable, Codable {
//    var id = UUID()
//    var date: Date          // day granularity
//    var dayName: String
//    var completedExercises: [String]  // exercise names
//    var notes: String
//    // For distance-type days (cycling, running)
//    var distanceKm: Double?
//    var durationMin: Int?
//}
//
//// MARK: Store
//
//final class GymStore: ObservableObject {
//    @Published var days: [GymDay] = []
//    @Published var logs: [GymLog] = []
//
//    private let daysKey = "gymDays_v1"
//    private let logsKey = "gymLogs_v1"
//
//    init() {
//        loadDays()
//        loadLogs()
//        if days.isEmpty { seedDefaults() }
//    }
//
//    // MARK: Days
//
//    func addDay(name: String) {
//        let d = GymDay(name: name, exercises: [])
//        days.append(d)
//        saveDays()
//    }
//
//    func deleteDay(at offsets: IndexSet) {
//        days.remove(atOffsets: offsets)
//        saveDays()
//    }
//
//    func addExercise(_ name: String, toDayWithID id: UUID) {
//        if let i = days.firstIndex(where: { $0.id == id }) {
//            days[i].exercises.append(GymExercise(name: name))
//            saveDays()
//        }
//    }
//
//    func deleteExercise(dayID: UUID, exerciseID: UUID) {
//        if let di = days.firstIndex(where: { $0.id == dayID }) {
//            days[di].exercises.removeAll { $0.id == exerciseID }
//            saveDays()
//        }
//    }
//
//    func moveExercises(dayID: UUID, from: IndexSet, to: Int) {
//        if let di = days.firstIndex(where: { $0.id == dayID }) {
//            days[di].exercises.move(fromOffsets: from, toOffset: to)
//            saveDays()
//        }
//    }
//
//    // MARK: Logs
//
//    func saveLog(_ log: GymLog) {
//        // Remove any existing log for same day+dayName today, then append
//        let cal = Calendar.current
//        logs.removeAll {
//            cal.isDate($0.date, inSameDayAs: log.date) && $0.dayName == log.dayName
//        }
//        logs.append(log)
//        saveLogs()
//    }
//
//    func logs(for dayName: String) -> [GymLog] {
//        logs.filter { $0.dayName == dayName }
//            .sorted { $0.date > $1.date }
//    }
//
//    func logsOnDate(_ date: Date) -> [GymLog] {
//        let cal = Calendar.current
//        return logs.filter { cal.isDate($0.date, inSameDayAs: date) }
//    }
//
//    // MARK: Persistence
//
//    private func saveDays() {
//        if let data = try? JSONEncoder().encode(days) {
//            UserDefaults.standard.set(data, forKey: daysKey)
//        }
//        objectWillChange.send()
//    }
//
//    private func loadDays() {
//        if let data = UserDefaults.standard.data(forKey: daysKey),
//           let decoded = try? JSONDecoder().decode([GymDay].self, from: data) {
//            days = decoded
//        }
//    }
//
//    private func saveLogs() {
//        if let data = try? JSONEncoder().encode(logs) {
//            UserDefaults.standard.set(data, forKey: logsKey)
//        }
//        objectWillChange.send()
//    }
//
//    private func loadLogs() {
//        if let data = UserDefaults.standard.data(forKey: logsKey),
//           let decoded = try? JSONDecoder().decode([GymLog].self, from: data) {
//            logs = decoded
//        }
//    }
//
//    private func seedDefaults() {
//        days = [
//            GymDay(name: "Chest", exercises: [
//                GymExercise(name: "Bench press 3×10"),
//                GymExercise(name: "Incline press 3×10"),
//                GymExercise(name: "Cable flies 3×12"),
//                GymExercise(name: "Push-ups 3×15"),
//            ]),
//            GymDay(name: "Back", exercises: [
//                GymExercise(name: "Deadlift 4×6"),
//                GymExercise(name: "Pull-ups 3×8"),
//                GymExercise(name: "Seated row 3×12"),
//                GymExercise(name: "Lat pulldown 3×10"),
//            ]),
//            GymDay(name: "Legs", exercises: [
//                GymExercise(name: "Squat 4×8"),
//                GymExercise(name: "Leg press 3×12"),
//                GymExercise(name: "Romanian DL 3×10"),
//                GymExercise(name: "Calf raises 4×15"),
//            ]),
//            GymDay(name: "Arms", exercises: [
//                GymExercise(name: "Barbell curl 3×10"),
//                GymExercise(name: "Hammer curl 3×12"),
//                GymExercise(name: "Tricep dip 3×12"),
//                GymExercise(name: "Skull crusher 3×10"),
//            ]),
//        ]
//        saveDays()
//    }
//}
//
//// MARK: GymSectionView
//
//struct GymSectionView: View {
//    let sectionColor: String
//    var onDismiss: () -> Void
//
//    @StateObject private var store = GymStore()
//    @State private var selectedDayID: UUID? = nil
//    @State private var completed: Set<UUID> = []
//    @State private var notes = ""
//    @State private var distanceKm = ""
//    @State private var durationMin = ""
//    @State private var showAddDay = false
//    @State private var newDayName = ""
//    @State private var showAddExercise = false
//    @State private var newExerciseName = ""
//    @State private var showHistory = false
//    @State private var showDayManager = false
//    @FocusState private var notesFocused: Bool
//
//    var accent: Color { Color(hex: sectionColor) }
//    var selectedDay: GymDay? { store.days.first(where: { $0.id == selectedDayID }) }
//
//    // Is today's log already saved for this day?
//    private var todayLogExists: Bool {
//        guard let day = selectedDay else { return false }
//        let cal = Calendar.current
//        return store.logs.contains { cal.isDateInToday($0.date) && $0.dayName == day.name }
//    }
//
//    // Does this day look like cardio (cycling / running / walk)?
//    private var isCardiDay: Bool {
//        guard let day = selectedDay else { return false }
//        let cardioKeywords = ["cycling", "cycle", "running", "run", "walk", "cardio", "swim"]
//        return cardioKeywords.contains(where: { day.name.lowercased().contains($0) })
//    }
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.10, green: 0.06, blue: 0.06).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                SectionHeader(
//                    icon: "figure.run",
//                    title: "Gym",
//                    accentColor: accent,
//                    trailing: AnyView(
//                        HStack(spacing: 8) {
//                            Button { showHistory = true } label: {
//                                Image(systemName: "clock.arrow.circlepath")
//                                    .font(.system(size: 15))
//                                    .foregroundColor(.white.opacity(0.6))
//                                    .padding(10)
//                                    .background(.white.opacity(0.08))
//                                    .clipShape(Circle())
//                            }
//                            Button { showDayManager = true } label: {
//                                Image(systemName: "slider.horizontal.3")
//                                    .font(.system(size: 15))
//                                    .foregroundColor(.white.opacity(0.6))
//                                    .padding(10)
//                                    .background(.white.opacity(0.08))
//                                    .clipShape(Circle())
//                            }
//                        }
//                    ),
//                    onDismiss: onDismiss
//                )
//
//                // Day selector chips — scrollable, user-defined
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 8) {
//                        ForEach(store.days) { day in
//                            Button {
//                                withAnimation(.spring()) {
//                                    selectedDayID = day.id
//                                    completed = []
//                                    notes = ""
//                                    distanceKm = ""
//                                    durationMin = ""
//                                    // Pre-fill if today's log exists
//                                    if let log = store.logs.first(where: {
//                                        Calendar.current.isDateInToday($0.date) && $0.dayName == day.name
//                                    }) {
//                                        for ex in day.exercises where log.completedExercises.contains(ex.name) {
//                                            completed.insert(ex.id)
//                                        }
//                                        notes = log.notes
//                                        if let km = log.distanceKm { distanceKm = String(format: "%.1f", km) }
//                                        if let min = log.durationMin { durationMin = "\(min)" }
//                                    }
//                                }
//                            } label: {
//                                Text(day.name)
//                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
//                                    .foregroundColor(selectedDayID == day.id ? .white : .white.opacity(0.4))
//                                    .padding(.horizontal, 16).padding(.vertical, 8)
//                                    .background(selectedDayID == day.id ? accent.opacity(0.85) : Color.white.opacity(0.07))
//                                    .cornerRadius(20)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 20)
//                                            .stroke(selectedDayID == day.id ? accent : .white.opacity(0.1), lineWidth: 1)
//                                    )
//                            }
//                        }
//
//                        // Quick-add day chip
//                        Button { showAddDay = true } label: {
//                            Image(systemName: "plus")
//                                .font(.system(size: 13, weight: .semibold))
//                                .foregroundColor(.white.opacity(0.4))
//                                .padding(.horizontal, 12).padding(.vertical, 8)
//                                .background(Color.white.opacity(0.05))
//                                .cornerRadius(20)
//                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.1), lineWidth: 1))
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                }
//                .padding(.bottom, 16)
//
//                if let day = selectedDay {
//                    ScrollView {
//                        LazyVStack(spacing: 10) {
//
//                            // Cardio distance/duration input
//                            if isCardiDay {
//                                HStack(spacing: 12) {
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text("Distance (km)").font(.system(size: 11, design: .rounded)).foregroundColor(.white.opacity(0.4))
//                                        TextField("e.g. 15", text: $distanceKm)
//                                            .keyboardType(.decimalPad)
//                                            .padding(.horizontal, 12).padding(.vertical, 10)
//                                            .background(.white.opacity(0.08)).cornerRadius(12)
//                                            .foregroundColor(.white).font(.system(size: 15, design: .rounded))
//                                    }
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text("Duration (min)").font(.system(size: 11, design: .rounded)).foregroundColor(.white.opacity(0.4))
//                                        TextField("e.g. 45", text: $durationMin)
//                                            .keyboardType(.numberPad)
//                                            .padding(.horizontal, 12).padding(.vertical, 10)
//                                            .background(.white.opacity(0.08)).cornerRadius(12)
//                                            .foregroundColor(.white).font(.system(size: 15, design: .rounded))
//                                    }
//                                }
//                                .padding(.horizontal, 20)
//                            }
//
//                            // Exercise list
//                            ForEach(day.exercises) { ex in
//                                GymExerciseRow(
//                                    name: ex.name,
//                                    accent: accent,
//                                    isDone: completed.contains(ex.id)
//                                ) {
//                                    withAnimation(.spring()) {
//                                        if completed.contains(ex.id) { completed.remove(ex.id) }
//                                        else { completed.insert(ex.id) }
//                                    }
//                                }
//                                .padding(.horizontal, 20)
//                            }
//
//                            // Add exercise button
//                            Button {
//                                showAddExercise = true
//                            } label: {
//                                HStack(spacing: 8) {
//                                    Image(systemName: "plus.circle").font(.system(size: 14))
//                                    Text("Add exercise").font(.system(size: 14, design: .rounded))
//                                }
//                                .foregroundColor(accent.opacity(0.8))
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 12)
//                                .background(accent.opacity(0.08))
//                                .cornerRadius(14)
//                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(accent.opacity(0.2), lineWidth: 1))
//                            }
//                            .padding(.horizontal, 20)
//
//                            // Notes field
//                            ZStack(alignment: .topLeading) {
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(.white.opacity(0.06))
//                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.1), lineWidth: 1))
//                                TextEditor(text: $notes)
//                                    .scrollContentBackground(.hidden).background(.clear)
//                                    .foregroundColor(.white.opacity(0.8))
//                                    .font(.system(size: 14, design: .rounded))
//                                    .padding(12).focused($notesFocused).frame(minHeight: 80)
//                                if notes.isEmpty {
//                                    Text("Session notes...").font(.system(size: 14, design: .rounded))
//                                        .foregroundColor(.white.opacity(0.2)).padding(16).allowsHitTesting(false)
//                                }
//                            }
//                            .padding(.horizontal, 20).padding(.top, 8)
//
//                            // Save session button
//                            Button { saveSession() } label: {
//                                HStack(spacing: 8) {
//                                    Image(systemName: todayLogExists ? "checkmark.circle.fill" : "square.and.arrow.down")
//                                        .font(.system(size: 15))
//                                    Text(todayLogExists ? "Update Today's Session" : "Save Session")
//                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
//                                }
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 14)
//                                .background(accent.opacity(0.85))
//                                .cornerRadius(16)
//                            }
//                            .padding(.horizontal, 20)
//                            .padding(.bottom, 30)
//                        }
//                    }
//                } else {
//                    Spacer()
//                    VStack(spacing: 12) {
//                        Image(systemName: "dumbbell").font(.system(size: 40, weight: .light)).foregroundColor(.white.opacity(0.15))
//                        Text("Select a workout day above").font(.system(size: 15, design: .rounded)).foregroundColor(.white.opacity(0.3))
//                    }
//                    Spacer()
//                }
//            }
//
//            // Add Day sheet
//            if showAddDay {
//                QuickInputOverlay(
//                    title: "New Day",
//                    placeholder: "e.g. Cycling, Shoulders…",
//                    accent: accent,
//                    value: $newDayName,
//                    onSave: {
//                        let name = newDayName.trimmingCharacters(in: .whitespaces)
//                        guard !name.isEmpty else { return }
//                        store.addDay(name: name)
//                        newDayName = ""
//                        showAddDay = false
//                    },
//                    onCancel: { showAddDay = false; newDayName = "" }
//                )
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//                .zIndex(20)
//            }
//
//            // Add Exercise sheet
//            if showAddExercise, let dayID = selectedDayID {
//                QuickInputOverlay(
//                    title: "New Exercise",
//                    placeholder: "e.g. Incline press 3×12",
//                    accent: accent,
//                    value: $newExerciseName,
//                    onSave: {
//                        let name = newExerciseName.trimmingCharacters(in: .whitespaces)
//                        guard !name.isEmpty else { return }
//                        store.addExercise(name, toDayWithID: dayID)
//                        newExerciseName = ""
//                        showAddExercise = false
//                    },
//                    onCancel: { showAddExercise = false; newExerciseName = "" }
//                )
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//                .zIndex(20)
//            }
//
//            // History overlay
//            if showHistory {
//                GymHistoryView(store: store, accent: accent) { showHistory = false }
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                    .zIndex(20)
//            }
//
//            // Day manager overlay
//            if showDayManager {
//                GymDayManagerView(store: store, accent: accent) { showDayManager = false }
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                    .zIndex(20)
//            }
//        }
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showAddDay)
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showAddExercise)
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showHistory)
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showDayManager)
//        .onAppear {
//            if selectedDayID == nil, let first = store.days.first {
//                selectedDayID = first.id
//            }
//        }
//        .onTapGesture { notesFocused = false }
//    }
//
//    private func saveSession() {
//        guard let day = selectedDay else { return }
//        let completedNames = day.exercises.filter { completed.contains($0.id) }.map { $0.name }
//        let log = GymLog(
//            date: Date(),
//            dayName: day.name,
//            completedExercises: completedNames,
//            notes: notes.trimmingCharacters(in: .whitespaces),
//            distanceKm: Double(distanceKm),
//            durationMin: Int(durationMin)
//        )
//        store.saveLog(log)
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//    }
//}
//
//// MARK: Gym Exercise Row
//
//private struct GymExerciseRow: View {
//    let name: String
//    let accent: Color
//    let isDone: Bool
//    let onTap: () -> Void
//
//    var body: some View {
//        Button(action: onTap) {
//            HStack(spacing: 12) {
//                ZStack {
//                    Circle().fill(isDone ? accent.opacity(0.8) : .clear).frame(width: 24, height: 24)
//                    Circle().strokeBorder(isDone ? accent : .white.opacity(0.3), lineWidth: 1.5).frame(width: 24, height: 24)
//                    if isDone { Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white) }
//                }
//                Text(name)
//                    .font(.system(size: 15, design: .rounded))
//                    .foregroundColor(isDone ? .white.opacity(0.35) : .white)
//                    .strikethrough(isDone, color: .white.opacity(0.35))
//                Spacer()
//            }
//            .padding(.horizontal, 14).padding(.vertical, 14)
//            .background(.white.opacity(0.07))
//            .cornerRadius(16)
//            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.1), lineWidth: 1))
//        }
//    }
//}
//
//// MARK: Quick Input Overlay (reusable)
//
//private struct QuickInputOverlay: View {
//    let title: String
//    let placeholder: String
//    let accent: Color
//    @Binding var value: String
//    let onSave: () -> Void
//    let onCancel: () -> Void
//    @FocusState private var focused: Bool
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.6).ignoresSafeArea()
//                .onTapGesture { onCancel() }
//
//            VStack(spacing: 16) {
//                Text(title)
//                    .font(.system(size: 18, weight: .semibold, design: .rounded))
//                    .foregroundColor(.white)
//
//                TextField(placeholder, text: $value)
//                    .padding(.horizontal, 16).padding(.vertical, 14)
//                    .background(.white.opacity(0.1)).cornerRadius(14)
//                    .foregroundColor(.white).font(.system(size: 15, design: .rounded))
//                    .focused($focused)
//                    .onSubmit { onSave() }
//
//                HStack(spacing: 12) {
//                    Button(action: onCancel) {
//                        Text("Cancel")
//                            .font(.system(size: 15, design: .rounded))
//                            .foregroundColor(.white.opacity(0.6))
//                            .frame(maxWidth: .infinity).padding(.vertical, 12)
//                            .background(.white.opacity(0.08)).cornerRadius(14)
//                    }
//                    Button(action: onSave) {
//                        Text("Add")
//                            .font(.system(size: 15, weight: .semibold, design: .rounded))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity).padding(.vertical, 12)
//                            .background(accent.opacity(0.85)).cornerRadius(14)
//                    }
//                    .disabled(value.trimmingCharacters(in: .whitespaces).isEmpty)
//                }
//            }
//            .padding(24)
//            .background(Color(red: 0.12, green: 0.10, blue: 0.18))
//            .cornerRadius(24)
//            .padding(.horizontal, 30)
//        }
//        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { focused = true } }
//    }
//}
//
//// MARK: Gym History View
//
//struct GymHistoryView: View {
//    @ObservedObject var store: GymStore
//    let accent: Color
//    let onDismiss: () -> Void
//
//    @State private var selectedDate = Date()
//
//    private var logsForSelected: [GymLog] { store.logsOnDate(selectedDate) }
//
//    private func dateLabel(_ date: Date) -> String {
//        let cal = Calendar.current
//        if cal.isDateInToday(date) { return "Today" }
//        if cal.isDateInYesterday(date) { return "Yesterday" }
//        let f = DateFormatter(); f.dateFormat = "d MMM yyyy"
//        return f.string(from: date)
//    }
//
//    // Get unique dates that have logs
//    private var logDates: [Date] {
//        var seen = Set<String>()
//        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
//        return store.logs.compactMap { log -> Date? in
//            let key = f.string(from: log.date)
//            if seen.contains(key) { return nil }
//            seen.insert(key)
//            return log.date
//        }.sorted { $0 > $1 }
//    }
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.08, green: 0.06, blue: 0.12).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // Header
//                HStack {
//                    Button(action: onDismiss) {
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 18, weight: .semibold)).foregroundColor(.white.opacity(0.8))
//                            .padding(12).background(.white.opacity(0.1)).clipShape(Circle())
//                    }
//                    Spacer()
//                    Text("Workout History")
//                        .font(.system(size: 20, weight: .semibold, design: .rounded)).foregroundColor(.white)
//                    Spacer()
//                    Circle().fill(.clear).frame(width: 44, height: 44)
//                }
//                .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 20)
//
//                if store.logs.isEmpty {
//                    Spacer()
//                    VStack(spacing: 12) {
//                        Image(systemName: "clock.arrow.circlepath").font(.system(size: 44, weight: .light)).foregroundColor(.white.opacity(0.15))
//                        Text("No sessions logged yet").font(.system(size: 16, design: .rounded)).foregroundColor(.white.opacity(0.3))
//                        Text("Complete a workout and tap Save Session").font(.system(size: 13, design: .rounded)).foregroundColor(.white.opacity(0.2))
//                    }
//                    Spacer()
//                } else {
//                    // Date picker strip
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 8) {
//                            ForEach(logDates, id: \.self) { date in
//                                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
//                                Button { selectedDate = date } label: {
//                                    Text(dateLabel(date))
//                                        .font(.system(size: 13, weight: .medium, design: .rounded))
//                                        .foregroundColor(isSelected ? .white : .white.opacity(0.4))
//                                        .padding(.horizontal, 14).padding(.vertical, 8)
//                                        .background(isSelected ? accent.opacity(0.8) : .white.opacity(0.07))
//                                        .cornerRadius(20)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                    }
//                    .padding(.bottom, 16)
//
//                    // Log cards for selected date
//                    if logsForSelected.isEmpty {
//                        VStack(spacing: 8) {
//                            Spacer()
//                            Text("No sessions on this date").font(.system(size: 15, design: .rounded)).foregroundColor(.white.opacity(0.3))
//                            Spacer()
//                        }
//                    } else {
//                        ScrollView {
//                            VStack(spacing: 14) {
//                                ForEach(logsForSelected) { log in
//                                    GymLogCard(log: log, accent: accent)
//                                }
//                            }
//                            .padding(.horizontal, 20).padding(.bottom, 40)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//private struct GymLogCard: View {
//    let log: GymLog
//    let accent: Color
//
//    private func timeLabel() -> String {
//        let f = DateFormatter(); f.dateFormat = "h:mm a"
//        return f.string(from: log.date)
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(log.dayName)
//                        .font(.system(size: 17, weight: .semibold, design: .rounded))
//                        .foregroundColor(.white)
//                    Text("Logged at \(timeLabel())")
//                        .font(.system(size: 11, design: .rounded))
//                        .foregroundColor(accent.opacity(0.7))
//                }
//                Spacer()
//                // Completion count badge
//                Text("\(log.completedExercises.count) done")
//                    .font(.system(size: 12, weight: .semibold, design: .rounded))
//                    .foregroundColor(accent)
//                    .padding(.horizontal, 10).padding(.vertical, 4)
//                    .background(accent.opacity(0.15)).cornerRadius(10)
//            }
//
//            // Distance / duration for cardio
//            if let km = log.distanceKm {
//                HStack(spacing: 16) {
//                    HStack(spacing: 4) {
//                        Image(systemName: "location.fill").font(.system(size: 12)).foregroundColor(accent)
//                        Text(String(format: "%.1f km", km)).font(.system(size: 13, design: .rounded)).foregroundColor(.white.opacity(0.8))
//                    }
//                    if let min = log.durationMin {
//                        HStack(spacing: 4) {
//                            Image(systemName: "clock.fill").font(.system(size: 12)).foregroundColor(accent)
//                            Text("\(min) min").font(.system(size: 13, design: .rounded)).foregroundColor(.white.opacity(0.8))
//                        }
//                    }
//                }
//            }
//
//            // Exercise list
//            if !log.completedExercises.isEmpty {
//                VStack(alignment: .leading, spacing: 4) {
//                    ForEach(log.completedExercises, id: \.self) { ex in
//                        HStack(spacing: 8) {
//                            Image(systemName: "checkmark.circle.fill")
//                                .font(.system(size: 12)).foregroundColor(accent.opacity(0.7))
//                            Text(ex)
//                                .font(.system(size: 13, design: .rounded))
//                                .foregroundColor(.white.opacity(0.7))
//                        }
//                    }
//                }
//            }
//
//            // Notes
//            if !log.notes.isEmpty {
//                Text(log.notes)
//                    .font(.system(size: 13, design: .rounded)).foregroundColor(.white.opacity(0.5))
//                    .padding(10).background(.white.opacity(0.05)).cornerRadius(10)
//            }
//        }
//        .padding(16)
//        .background(.white.opacity(0.07))
//        .cornerRadius(18)
//        .overlay(RoundedRectangle(cornerRadius: 18).stroke(accent.opacity(0.15), lineWidth: 1))
//    }
//}
//
//// MARK: Gym Day Manager (edit / delete / reorder days)
//
//struct GymDayManagerView: View {
//    @ObservedObject var store: GymStore
//    let accent: Color
//    let onDismiss: () -> Void
//
//    @State private var showAddDay = false
//    @State private var newDayName = ""
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.08, green: 0.06, blue: 0.12).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                HStack {
//                    Button(action: onDismiss) {
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 18, weight: .semibold)).foregroundColor(.white.opacity(0.8))
//                            .padding(12).background(.white.opacity(0.1)).clipShape(Circle())
//                    }
//                    Spacer()
//                    Text("Manage Days")
//                        .font(.system(size: 20, weight: .semibold, design: .rounded)).foregroundColor(.white)
//                    Spacer()
//                    Button { showAddDay = true } label: {
//                        Image(systemName: "plus")
//                            .font(.system(size: 15, weight: .semibold)).foregroundColor(.white.opacity(0.7))
//                            .padding(12).background(.white.opacity(0.08)).clipShape(Circle())
//                    }
//                }
//                .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 8)
//
//                Text("Swipe to delete · Drag ≡ to reorder")
//                    .font(.system(size: 11, design: .rounded)).foregroundColor(.white.opacity(0.25))
//                    .padding(.bottom, 12)
//
//                List {
//                    ForEach(store.days) { day in
//                        HStack {
//                            Image(systemName: "line.3.horizontal")
//                                .font(.system(size: 14)).foregroundColor(.white.opacity(0.3))
//                            Text(day.name)
//                                .font(.system(size: 15, design: .rounded)).foregroundColor(.white)
//                            Spacer()
//                            Text("\(day.exercises.count) exercises")
//                                .font(.system(size: 12, design: .rounded)).foregroundColor(.white.opacity(0.35))
//                        }
//                        .listRowBackground(Color.white.opacity(0.07))
//                        .listRowSeparatorTint(.white.opacity(0.08))
//                    }
//                    .onDelete { offsets in store.deleteDay(at: offsets) }
//                    .onMove { from, to in
//                        store.days.move(fromOffsets: from, toOffset: to)
//                    }
//                }
//                .listStyle(.plain)
//                .scrollContentBackground(.hidden)
//                .environment(\.editMode, .constant(.active))
//            }
//
//            if showAddDay {
//                QuickInputOverlay(
//                    title: "New Day",
//                    placeholder: "e.g. Cycling, Shoulders…",
//                    accent: accent,
//                    value: $newDayName,
//                    onSave: {
//                        let name = newDayName.trimmingCharacters(in: .whitespaces)
//                        guard !name.isEmpty else { return }
//                        store.addDay(name: name)
//                        newDayName = ""
//                        showAddDay = false
//                    },
//                    onCancel: { showAddDay = false; newDayName = "" }
//                )
//                .transition(.opacity.combined(with: .scale(scale: 0.96)))
//                .zIndex(10)
//            }
//        }
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showAddDay)
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - 4. JOURNAL SECTION  (unchanged from original)
//// ─────────────────────────────────────────────────────────────
//
//struct JournalEntry: Identifiable {
//    var id = UUID()
//    var text: AttributedString
//    var rawText: String
//    var date: Date = Date()
//}
//
//struct JournalSectionView: View {
//    let sectionColor: String
//    @ObservedObject var noteStore: NoteStore
//    var onDismiss: () -> Void
//
//    @State private var entryText = ""
//    @State private var selectedColor: Color = .white
//    @State private var showPhoto = false
//    @State private var photoItem: PhotosPickerItem? = nil
//    @State private var selectedImage: UIImage? = nil
//    @State private var savedEntries: [String] = []
//    @FocusState private var focused: Bool
//
//    let textColors: [(Color, String)] = [(.white, "FFFFFF"), (.yellow, "FFD60A"), (Color(hex: "FF6B6B"), "FF6B6B"), (Color(hex: "69DB7C"), "69DB7C")]
//    var accent: Color { Color(hex: sectionColor) }
//
//    private var dateLabel: String {
//        let f = DateFormatter()
//        f.dateFormat = "d MMM yyyy"
//        return f.string(from: Date()).uppercased()
//    }
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.08, green: 0.08, blue: 0.14).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                SectionHeader(icon: "notebook", title: "Journal", accentColor: accent, onDismiss: onDismiss)
//
//                Text(dateLabel)
//                    .font(.system(size: 11, weight: .medium, design: .rounded))
//                    .tracking(2)
//                    .foregroundColor(.white.opacity(0.35))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 12)
//
//                ZStack(alignment: .topLeading) {
//                    RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.1, green: 0.1, blue: 0.17))
//                    GeometryReader { geo in
//                        let lineH: CGFloat = 28
//                        let count = Int(geo.size.height / lineH) + 1
//                        VStack(spacing: 0) {
//                            ForEach(0..<count, id: \.self) { _ in
//                                VStack(spacing: 0) {
//                                    Spacer()
//                                    Rectangle().fill(.white.opacity(0.06)).frame(height: 0.5)
//                                }.frame(height: lineH)
//                            }
//                        }
//                        .padding(.horizontal, 16).padding(.top, 12)
//                    }
//
//                    ScrollView {
//                        VStack(alignment: .leading, spacing: 0) {
//                            ForEach(savedEntries, id: \.self) { entry in
//                                Text(entry)
//                                    .font(.system(size: 15, design: .rounded))
//                                    .foregroundColor(.white.opacity(0.8))
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.horizontal, 20).padding(.top, 14)
//                                    .lineSpacing(14)
//                            }
//                            if let img = selectedImage {
//                                Image(uiImage: img).resizable().scaledToFit()
//                                    .cornerRadius(12).padding(.horizontal, 20).padding(.top, 10)
//                            }
//                            TextEditor(text: $entryText)
//                                .scrollContentBackground(.hidden).background(.clear)
//                                .foregroundColor(selectedColor)
//                                .font(.system(size: 15, design: .rounded)).lineSpacing(14)
//                                .focused($focused).frame(minHeight: 140)
//                                .padding(.horizontal, 16).padding(.top, savedEntries.isEmpty && selectedImage == nil ? 14 : 4)
//                            if entryText.isEmpty && savedEntries.isEmpty && selectedImage == nil {
//                                Text("Today felt long but good...")
//                                    .font(.system(size: 15, design: .rounded)).foregroundColor(.white.opacity(0.18))
//                                    .padding(.horizontal, 20).padding(.top, 14).allowsHitTesting(false)
//                            }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity).frame(height: 320)
//                .padding(.horizontal, 20)
//                .onTapGesture { focused = true }
//
//                Spacer(minLength: 0)
//
//                HStack(spacing: 12) {
//                    PhotosPicker(selection: $photoItem, matching: .images) {
//                        HStack(spacing: 5) {
//                            Image(systemName: "photo").font(.system(size: 13))
//                            Text("Photo").font(.system(size: 12, design: .rounded))
//                        }
//                        .foregroundColor(.white.opacity(0.55)).padding(.horizontal, 12).padding(.vertical, 8)
//                        .background(.white.opacity(0.08)).cornerRadius(20)
//                    }
//                    .onChange(of: photoItem) {
//                        Task {
//                            if let data = try? await photoItem?.loadTransferable(type: Data.self),
//                               let img = UIImage(data: data) { selectedImage = img }
//                        }
//                    }
//
//                    Menu {
//                        ForEach(["😊", "😐", "😔", "😤", "🥰", "😴"], id: \.self) { emoji in
//                            Button(emoji) { entryText += " \(emoji)" }
//                        }
//                    } label: {
//                        HStack(spacing: 5) {
//                            Text("☺").font(.system(size: 13))
//                            Text("Mood").font(.system(size: 12, design: .rounded))
//                        }
//                        .foregroundColor(.white.opacity(0.55)).padding(.horizontal, 12).padding(.vertical, 8)
//                        .background(.white.opacity(0.08)).cornerRadius(20)
//                    }
//
//                    Menu {
//                        ForEach(textColors, id: \.1) { (col, _) in
//                            Button {
//                                selectedColor = col
//                            } label: {
//                                Label(col == .white ? "White" : col == .yellow ? "Yellow" : col == Color(hex: "FF6B6B") ? "Red" : "Green",
//                                      systemImage: "circle.fill")
//                            }
//                        }
//                    } label: {
//                        HStack(spacing: 5) {
//                            Circle().fill(selectedColor).frame(width: 10, height: 10)
//                            Text("Colour").font(.system(size: 12, design: .rounded))
//                        }
//                        .foregroundColor(.white.opacity(0.55)).padding(.horizontal, 12).padding(.vertical, 8)
//                        .background(.white.opacity(0.08)).cornerRadius(20)
//                    }
//
//                    Spacer()
//
//                    Button {
//                        let t = entryText.trimmingCharacters(in: .whitespaces)
//                        guard !t.isEmpty else { return }
//                        withAnimation { savedEntries.append(t) }
//                        entryText = ""
//                        let note = Note(title: dateLabel, content: savedEntries.joined(separator: "\n"), sectionName: "Journal")
//                        noteStore.save(note: note)
//                    } label: {
//                        Image(systemName: "arrow.up.circle.fill").font(.system(size: 30)).foregroundColor(accent)
//                    }
//                    .disabled(entryText.trimmingCharacters(in: .whitespaces).isEmpty)
//                }
//                .padding(.horizontal, 20).padding(.vertical, 14).background(.white.opacity(0.03))
//            }
//        }
//        .onAppear {
//            let entries = noteStore.notes(for: "Journal")
//            if let today = entries.first(where: { $0.title == dateLabel }) {
//                savedEntries = today.content.components(separatedBy: "\n").filter { !$0.isEmpty }
//            }
//        }
//        .onTapGesture { focused = false }
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - 5. SPIRITUALITY SECTION  (unchanged)
//// ─────────────────────────────────────────────────────────────
//
//struct PrayerCard: Identifiable {
//    var id = UUID()
//    var name: String
//    var subtitle: String
//    var frequency: String
//    var time: String?
//    var isCompleted: Bool = false
//    var icon: String = "hands.sparkles"
//}
//
//struct SpiritualitySectionView: View {
//    let sectionColor: String
//    var onDismiss: () -> Void
//    var accent: Color { Color(hex: sectionColor) }
//
//    @State private var prayers: [PrayerCard] = [
//        PrayerCard(name: "Hanuman Chalisa", subtitle: "", frequency: "1× daily", time: nil, icon: "hands.sparkles"),
//        PrayerCard(name: "Morning prayer", subtitle: "", frequency: "", time: "7 AM", icon: "sun.horizon"),
//        PrayerCard(name: "Meditation", subtitle: "", frequency: "2× daily", time: "10 min", icon: "brain.head.profile"),
//    ]
//    @State private var showAdd = false
//    @State private var newName = ""
//    @State private var newFreq = "1× daily"
//    @State private var newTime = ""
//
//    let freqOptions = ["1× daily", "2× daily", "3× daily", "Weekly"]
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.07, green: 0.09, blue: 0.15).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                SectionHeader(icon: "sparkles", title: "Spirituality", accentColor: accent,
//                              trailing: AnyView(
//                                Button { withAnimation(.spring()) { showAdd.toggle() } } label: {
//                                    Image(systemName: showAdd ? "xmark" : "plus")
//                                        .font(.system(size: 15, weight: .semibold))
//                                        .foregroundColor(.white.opacity(0.7))
//                                        .padding(12).background(.white.opacity(0.08)).clipShape(Circle())
//                                }
//                              ),
//                              onDismiss: onDismiss)
//
//                if showAdd {
//                    VStack(spacing: 12) {
//                        TextField("Prayer / practice name...", text: $newName)
//                            .padding(.horizontal, 14).padding(.vertical, 12)
//                            .background(.white.opacity(0.08)).cornerRadius(14)
//                            .foregroundColor(.white).font(.system(size: 14, design: .rounded))
//                        HStack(spacing: 8) {
//                            ForEach(freqOptions, id: \.self) { opt in
//                                Button { newFreq = opt } label: {
//                                    Text(opt)
//                                        .font(.system(size: 11, weight: .medium, design: .rounded))
//                                        .foregroundColor(newFreq == opt ? .white : .white.opacity(0.4))
//                                        .padding(.horizontal, 10).padding(.vertical, 6)
//                                        .background(newFreq == opt ? accent.opacity(0.5) : Color.white.opacity(0.06))
//                                        .cornerRadius(10)
//                                }
//                            }
//                        }
//                        HStack {
//                            TextField("Time (e.g. 7 AM)", text: $newTime)
//                                .padding(.horizontal, 14).padding(.vertical, 10)
//                                .background(.white.opacity(0.08)).cornerRadius(12)
//                                .foregroundColor(.white).font(.system(size: 13, design: .rounded))
//                            Button {
//                                let n = newName.trimmingCharacters(in: .whitespaces)
//                                guard !n.isEmpty else { return }
//                                withAnimation {
//                                    prayers.append(PrayerCard(name: n, subtitle: "", frequency: newFreq, time: newTime.isEmpty ? nil : newTime))
//                                    newName = ""; newTime = ""; showAdd = false
//                                }
//                            } label: {
//                                Image(systemName: "plus.circle.fill").font(.system(size: 32)).foregroundColor(accent)
//                            }
//                            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
//                        }
//                    }
//                    .padding(.horizontal, 20).padding(.bottom, 16)
//                    .transition(.move(edge: .top).combined(with: .opacity))
//                }
//
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach($prayers) { $prayer in
//                            PrayerCardRow(prayer: $prayer, accent: accent) {
//                                withAnimation { prayers.removeAll { $0.id == prayer.id } }
//                            }
//                            .padding(.horizontal, 20)
//                        }
//                    }
//                    .padding(.bottom, 30)
//                }
//            }
//        }
//    }
//}
//
//private struct PrayerCardRow: View {
//    @Binding var prayer: PrayerCard
//    let accent: Color
//    let onDelete: () -> Void
//    @State private var offset: CGFloat = 0
//    @State private var showDelete = false
//
//    var body: some View {
//        ZStack(alignment: .trailing) {
//            Button(action: onDelete) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 18).fill(Color.red.opacity(0.75))
//                    Image(systemName: "trash").font(.system(size: 15)).foregroundColor(.white)
//                }
//                .frame(width: 66)
//            }
//            .opacity(showDelete ? 1 : 0)
//
//            HStack(spacing: 14) {
//                Button { withAnimation(.spring()) { prayer.isCompleted.toggle() } } label: {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 8).fill(prayer.isCompleted ? accent.opacity(0.85) : .clear).frame(width: 28, height: 28)
//                        RoundedRectangle(cornerRadius: 8).strokeBorder(prayer.isCompleted ? accent : .white.opacity(0.3), lineWidth: 1.5).frame(width: 28, height: 28)
//                        if prayer.isCompleted { Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(.white) }
//                    }
//                }
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(prayer.name).font(.system(size: 16, weight: .semibold, design: .rounded))
//                        .foregroundColor(prayer.isCompleted ? .white.opacity(0.4) : .white)
//                    HStack(spacing: 8) {
//                        if !prayer.frequency.isEmpty {
//                            Text(prayer.frequency).font(.system(size: 11, design: .rounded))
//                                .foregroundColor(accent.opacity(0.85)).padding(.horizontal, 8).padding(.vertical, 3)
//                                .background(accent.opacity(0.15)).cornerRadius(8)
//                        }
//                        if let t = prayer.time, !t.isEmpty {
//                            Text(t).font(.system(size: 11, design: .rounded)).foregroundColor(.white.opacity(0.45))
//                        }
//                    }
//                }
//                Spacer()
//                Image(systemName: prayer.icon).font(.system(size: 18, weight: .light)).foregroundColor(accent.opacity(0.5))
//            }
//            .padding(.horizontal, 16).padding(.vertical, 16)
//            .background(.white.opacity(0.07)).cornerRadius(18)
//            .overlay(RoundedRectangle(cornerRadius: 18).stroke(accent.opacity(0.15), lineWidth: 1))
//            .offset(x: offset)
//            .gesture(
//                DragGesture()
//                    .onChanged { v in if v.translation.width < 0 { offset = max(v.translation.width, -76) } }
//                    .onEnded { v in
//                        withAnimation(.spring()) {
//                            if v.translation.width < -46 { offset = -76; showDelete = true }
//                            else { offset = 0; showDelete = false }
//                        }
//                    }
//            )
//            .onTapGesture { if showDelete { withAnimation { offset = 0; showDelete = false } } }
//        }
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - GENERIC (fallback) SECTION
//// ─────────────────────────────────────────────────────────────
//struct GenericSectionView: View {
//    let sectionName: String
//    let sectionIcon: String
//    let sectionColor: String
//    @Binding var tasks: [String]
//    @ObservedObject var noteStore: NoteStore
//    var onDismiss: () -> Void
//
//    @State private var selectedTab: SectionTab = .checklist
//    @State private var newTask = ""
//    @State private var showDatePicker = false
//    @State private var showNotesList = false
//    @State private var showNoteEditor = false
//    @State private var editingNote: Note? = nil
//    @State private var reminderDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
//
//    enum SectionTab { case checklist, notes }
//    var accentColor: Color { Color(hex: sectionColor) }
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.08, green: 0.08, blue: 0.14).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                SectionHeader(icon: sectionIcon, title: sectionName, accentColor: accentColor, onDismiss: onDismiss)
//
//                HStack(spacing: 8) {
//                    TabPill(title: "Checklist", icon: "checklist", isSelected: selectedTab == .checklist, accent: accentColor) { selectedTab = .checklist }
//                    TabPill(title: "Notes", icon: "note.text", isSelected: selectedTab == .notes, accent: accentColor) { selectedTab = .notes }
//                }
//                .padding(.horizontal, 20).padding(.bottom, 12)
//
//                if selectedTab == .checklist { checklistTab } else { notesTab }
//            }
//
//            if showNotesList {
//                NotesListView(sectionName: sectionName, accentColor: accentColor, noteStore: noteStore,
//                              onSelect: { note in editingNote = note; showNotesList = false; showNoteEditor = true },
//                              onDismiss: { showNotesList = false })
//                    .transition(.move(edge: .bottom).combined(with: .opacity)).zIndex(10)
//            }
//            if showNoteEditor {
//                NoteEditorView(sectionName: sectionName, accentColor: accentColor, noteStore: noteStore,
//                               existingNote: editingNote,
//                               onDismiss: { showNoteEditor = false; editingNote = nil })
//                    .transition(.move(edge: .bottom).combined(with: .opacity)).zIndex(10)
//            }
//        }
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showNotesList)
//        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showNoteEditor)
//    }
//
//    private var checklistTab: some View {
//        VStack(spacing: 0) {
//            Text("Swipe left to delete")
//                .font(.system(size: 11, design: .rounded)).foregroundColor(.white.opacity(0.25)).padding(.bottom, 10)
//            TaskListView(tasks: $tasks)
//            if showDatePicker {
//                HStack {
//                    Image(systemName: "bell.fill").font(.system(size: 13)).foregroundColor(accentColor)
//                    Text("Remind me at").font(.system(size: 13, design: .rounded)).foregroundColor(.white.opacity(0.7))
//                    Spacer()
//                    Button { withAnimation { showDatePicker = false } } label: {
//                        Image(systemName: "xmark").font(.system(size: 13)).foregroundColor(.white.opacity(0.4))
//                    }
//                }
//                .padding(.horizontal, 20).padding(.top, 10)
//                DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
//                    .datePickerStyle(.compact).colorScheme(.dark).labelsHidden()
//                    .padding(.horizontal, 20)
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//            }
//            HStack(spacing: 10) {
//                TextField("Add a task...", text: $newTask)
//                    .padding(.horizontal, 16).padding(.vertical, 14)
//                    .background(.white.opacity(0.08)).cornerRadius(18)
//                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.12), lineWidth: 1))
//                    .foregroundColor(.white).font(.system(size: 16, design: .rounded))
//                    .onSubmit { addTask() }
//                Button { withAnimation { showDatePicker.toggle() } } label: {
//                    Image(systemName: showDatePicker ? "bell.fill" : "bell")
//                        .font(.system(size: 20)).foregroundColor(showDatePicker ? accentColor : .white.opacity(0.4))
//                }
//                Button(action: addTask) {
//                    Image(systemName: "plus.circle.fill").font(.system(size: 36)).foregroundColor(accentColor)
//                }
//                .disabled(newTask.trimmingCharacters(in: .whitespaces).isEmpty)
//            }
//            .padding(.horizontal, 20).padding(.vertical, 16).background(.white.opacity(0.03))
//        }
//    }
//
//    private var notesTab: some View {
//        VStack(spacing: 12) {
//            HStack(spacing: 10) {
//                Button { editingNote = nil; showNoteEditor = true } label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "square.and.pencil").font(.system(size: 14))
//                        Text("New note").font(.system(size: 14, weight: .medium, design: .rounded))
//                    }
//                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 12)
//                    .background(accentColor.opacity(0.3)).cornerRadius(14)
//                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(accentColor.opacity(0.5), lineWidth: 1))
//                }
//                Button { showNotesList = true } label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "list.bullet").font(.system(size: 14))
//                        Text("All notes").font(.system(size: 14, weight: .medium, design: .rounded))
//                    }
//                    .foregroundColor(.white.opacity(0.7)).frame(maxWidth: .infinity).padding(.vertical, 12)
//                    .background(.white.opacity(0.08)).cornerRadius(14)
//                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.12), lineWidth: 1))
//                }
//            }
//            .padding(.horizontal, 20)
//
//            let recentNotes = noteStore.notes(for: sectionName)
//            if recentNotes.isEmpty {
//                VStack(spacing: 16) {
//                    Spacer()
//                    Image(systemName: "note.text").font(.system(size: 40, weight: .light)).foregroundColor(.white.opacity(0.15))
//                    Text("No notes yet").font(.system(size: 15, design: .rounded)).foregroundColor(.white.opacity(0.25))
//                    Spacer()
//                }
//            } else {
//                ScrollView {
//                    VStack(spacing: 10) {
//                        ForEach(recentNotes.prefix(5)) { note in
//                            Button { editingNote = note; showNoteEditor = true } label: {
//                                HStack(alignment: .top, spacing: 12) {
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text(note.title.isEmpty ? "Untitled" : note.title)
//                                            .font(.system(size: 15, weight: .medium, design: .rounded))
//                                            .foregroundColor(.white).lineLimit(1)
//                                        Text(note.content.isEmpty ? "No content" : note.content)
//                                            .font(.system(size: 12, design: .rounded))
//                                            .foregroundColor(.white.opacity(0.4)).lineLimit(2)
//                                    }
//                                    Spacer()
//                                    Text(note.formattedDate).font(.system(size: 10, design: .rounded)).foregroundColor(.white.opacity(0.3))
//                                }
//                                .padding(14).background(.white.opacity(0.07)).cornerRadius(16)
//                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 1))
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 20).padding(.bottom, 20)
//                }
//            }
//        }
//    }
//
//    private func addTask() {
//        let t = newTask.trimmingCharacters(in: .whitespaces)
//        guard !t.isEmpty else { return }
//        withAnimation { tasks.insert(t, at: 0) }
//        if showDatePicker {
//            NotificationManager.shared.scheduleTaskReminder(task: t, at: reminderDate, section: sectionName)
//            showDatePicker = false
//        }
//        newTask = ""
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - Note Editor
//// ─────────────────────────────────────────────────────────────
//struct NoteEditorView: View {
//    let sectionName: String
//    let accentColor: Color
//    @ObservedObject var noteStore: NoteStore
//    var existingNote: Note?
//    var onDismiss: () -> Void
//
//    @State private var title = ""
//    @State private var content = ""
//    @FocusState private var contentFocused: Bool
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.08, green: 0.08, blue: 0.14).ignoresSafeArea()
//            VStack(spacing: 0) {
//                HStack {
//                    Button(action: onDismiss) {
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 18, weight: .semibold)).foregroundColor(.white.opacity(0.8))
//                            .padding(12).background(.white.opacity(0.1)).clipShape(Circle())
//                    }
//                    Spacer()
//                    Text(existingNote == nil ? "New Note" : "Edit Note")
//                        .font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundColor(.white)
//                    Spacer()
//                    Button { saveNote(); onDismiss() } label: {
//                        Text("Save")
//                            .font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(accentColor)
//                            .padding(.horizontal, 16).padding(.vertical, 8)
//                            .background(accentColor.opacity(0.15)).cornerRadius(20)
//                    }
//                }
//                .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 20)
//
//                TextField("Title", text: $title)
//                    .font(.system(size: 22, weight: .semibold, design: .rounded))
//                    .foregroundColor(.white).padding(.horizontal, 20).padding(.bottom, 12)
//
//                Divider().background(.white.opacity(0.1)).padding(.horizontal, 20).padding(.bottom, 12)
//
//                ZStack(alignment: .topLeading) {
//                    GeometryReader { geo in
//                        let lineH: CGFloat = 28
//                        let count = Int(geo.size.height / lineH) + 1
//                        VStack(spacing: 0) {
//                            ForEach(0..<count, id: \.self) { _ in
//                                VStack(spacing: 0) {
//                                    Spacer()
//                                    Rectangle().fill(.white.opacity(0.06)).frame(height: 0.5)
//                                }.frame(height: lineH)
//                            }
//                        }
//                    }
//                    TextEditor(text: $content)
//                        .scrollContentBackground(.hidden).background(.clear)
//                        .foregroundColor(.white.opacity(0.85))
//                        .font(.system(size: 16, design: .rounded)).lineSpacing(12)
//                        .padding(.horizontal, 20).focused($contentFocused)
//                    if content.isEmpty {
//                        Text("Start writing...")
//                            .font(.system(size: 16, design: .rounded)).foregroundColor(.white.opacity(0.2))
//                            .padding(.horizontal, 24).padding(.top, 8).allowsHitTesting(false)
//                    }
//                }
//                Spacer()
//            }
//        }
//        .onAppear {
//            if let note = existingNote { title = note.title; content = note.content }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { contentFocused = true }
//        }
//    }
//
//    private func saveNote() {
//        let trimTitle = title.trimmingCharacters(in: .whitespaces)
//        let trimContent = content.trimmingCharacters(in: .whitespaces)
//        guard !trimTitle.isEmpty || !trimContent.isEmpty else { return }
//        var note = existingNote ?? Note(title: trimTitle.isEmpty ? "Untitled" : trimTitle, content: trimContent, sectionName: sectionName)
//        note.title = trimTitle.isEmpty ? "Untitled" : trimTitle
//        note.content = trimContent
//        noteStore.save(note: note)
//    }
//}
//
//// ─────────────────────────────────────────────────────────────
//// MARK: - Notes List View
//// ─────────────────────────────────────────────────────────────
//struct NotesListView: View {
//    let sectionName: String
//    let accentColor: Color
//    @ObservedObject var noteStore: NoteStore
//    var onSelect: (Note) -> Void
//    var onDismiss: () -> Void
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.08, green: 0.08, blue: 0.14).ignoresSafeArea()
//            VStack(spacing: 0) {
//                HStack {
//                    Button(action: onDismiss) {
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 18, weight: .semibold)).foregroundColor(.white.opacity(0.8))
//                            .padding(12).background(.white.opacity(0.1)).clipShape(Circle())
//                    }
//                    Spacer()
//                    Text("\(sectionName) Notes")
//                        .font(.system(size: 20, weight: .semibold, design: .rounded)).foregroundColor(.white)
//                    Spacer()
//                    Circle().fill(.clear).frame(width: 44, height: 44)
//                }
//                .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 20)
//
//                let notes = noteStore.notes(for: sectionName)
//                if notes.isEmpty {
//                    Spacer()
//                    VStack(spacing: 12) {
//                        Image(systemName: "note.text").font(.system(size: 44, weight: .light)).foregroundColor(.white.opacity(0.15))
//                        Text("No notes yet").font(.system(size: 16, design: .rounded)).foregroundColor(.white.opacity(0.3))
//                    }
//                    Spacer()
//                } else {
//                    ScrollView {
//                        VStack(spacing: 10) {
//                            ForEach(notes) { note in
//                                Button { onSelect(note) } label: {
//                                    HStack(alignment: .top) {
//                                        VStack(alignment: .leading, spacing: 6) {
//                                            Text(note.title.isEmpty ? "Untitled" : note.title)
//                                                .font(.system(size: 16, weight: .medium, design: .rounded))
//                                                .foregroundColor(.white).lineLimit(1)
//                                            Text(note.content.isEmpty ? "No content" : note.content)
//                                                .font(.system(size: 13, design: .rounded))
//                                                .foregroundColor(.white.opacity(0.4)).lineLimit(2)
//                                            Text(note.formattedDate)
//                                                .font(.system(size: 11, design: .rounded))
//                                                .foregroundColor(accentColor.opacity(0.7))
//                                        }
//                                        Spacer()
//                                        Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(.white.opacity(0.2))
//                                    }
//                                    .padding(16).background(.white.opacity(0.07)).cornerRadius(16)
//                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 1))
//                                }
//                                .contextMenu {
//                                    Button(role: .destructive) { noteStore.delete(note) } label: {
//                                        Label("Delete", systemImage: "trash")
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 20).padding(.bottom, 40)
//                    }
//                }
//            }
//        }
//    }
//}

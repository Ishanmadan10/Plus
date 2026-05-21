import SwiftUI

struct WorkSectionView: View {
    let sectionColor: String
    @Binding var tasks: [String]
    @ObservedObject var noteStore: NoteStore
    var onDismiss: () -> Void

    enum Tab { case checklist, notes }

    @State private var tab: Tab = .checklist
    @State private var newTask = ""
    @State private var showDatePicker = false
    @State private var reminderDate =
        Calendar.current.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: Date()
        ) ?? Date()

    @State private var showNoteEditor = false
    @State private var showNotesList = false
    @State private var editingNote: Note? = nil

    var accent: Color {
        Color(hex: sectionColor)
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.14)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                SectionHeader(
                    icon: "briefcase",
                    title: "Work",
                    accentColor: accent,
                    onDismiss: onDismiss
                )

                HStack(spacing: 8) {

                    TabPill(
                        title: "Checklist",
                        icon: "checklist",
                        isSelected: tab == .checklist,
                        accent: accent
                    ) {
                        tab = .checklist
                    }

                    TabPill(
                        title: "Notes",
                        icon: "note.text",
                        isSelected: tab == .notes,
                        accent: accent
                    ) {
                        tab = .notes
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

                if tab == .checklist {
                    workChecklist
                } else {
                    workNotes
                }
            }

            if showNoteEditor {
                NoteEditorView(
                    sectionName: "Work",
                    accentColor: accent,
                    noteStore: noteStore,
                    existingNote: editingNote,
                    onDismiss: {
                        showNoteEditor = false
                        editingNote = nil
                    }
                )
                .transition(
                    .move(edge: .bottom)
                    .combined(with: .opacity)
                )
                .zIndex(10)
            }

            if showNotesList {
                NotesListView(
                    sectionName: "Work",
                    accentColor: accent,
                    noteStore: noteStore,
                    onSelect: { note in
                        editingNote = note
                        showNotesList = false
                        showNoteEditor = true
                    },
                    onDismiss: {
                        showNotesList = false
                    }
                )
                .transition(
                    .move(edge: .bottom)
                    .combined(with: .opacity)
                )
                .zIndex(10)
            }
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.85),
            value: showNoteEditor
        )
        .animation(
            .spring(response: 0.35, dampingFraction: 0.85),
            value: showNotesList
        )
    }

    private var workChecklist: some View {
        VStack(spacing: 0) {

            Text("Swipe left to delete")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.white.opacity(0.25))
                .padding(.bottom, 10)

            TaskListView(tasks: $tasks)

            if showDatePicker {

                HStack {

                    Image(systemName: "bell.fill")
                        .font(.system(size: 13))
                        .foregroundColor(accent)

                    Text("Remind me at")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    Button {
                        withAnimation {
                            showDatePicker = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                DatePicker(
                    "",
                    selection: $reminderDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .colorScheme(.dark)
                .labelsHidden()
                .padding(.horizontal, 20)
                .transition(
                    .move(edge: .bottom)
                    .combined(with: .opacity)
                )
            }

            HStack(spacing: 10) {

                TextField("Add a task...", text: $newTask)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.08))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 16, design: .rounded))
                    .onSubmit {
                        addTask()
                    }

                Button {
                    withAnimation(.spring()) {
                        showDatePicker.toggle()
                    }
                } label: {
                    Image(
                        systemName: showDatePicker
                        ? "bell.fill"
                        : "bell"
                    )
                    .font(.system(size: 20))
                    .foregroundColor(
                        showDatePicker
                        ? accent
                        : .white.opacity(0.4)
                    )
                }

                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(accent)
                }
                .disabled(
                    newTask
                        .trimmingCharacters(in: .whitespaces)
                        .isEmpty
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.white.opacity(0.03))
        }
    }

    private var workNotes: some View {

        VStack(spacing: 12) {

            HStack(spacing: 10) {

                Button {

                    editingNote = nil
                    showNoteEditor = true

                } label: {

                    HStack(spacing: 6) {

                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14))

                        Text("New note")
                            .font(
                                .system(
                                    size: 14,
                                    weight: .medium,
                                    design: .rounded
                                )
                            )
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(accent.opacity(0.3))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                accent.opacity(0.5),
                                lineWidth: 1
                            )
                    )
                }

                Button {
                    showNotesList = true
                } label: {

                    HStack(spacing: 6) {

                        Image(systemName: "list.bullet")
                            .font(.system(size: 14))

                        Text("All notes")
                            .font(
                                .system(
                                    size: 14,
                                    weight: .medium,
                                    design: .rounded
                                )
                            )
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.08))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                .white.opacity(0.12),
                                lineWidth: 1
                            )
                    )
                }
            }
            .padding(.horizontal, 20)

            ZStack(alignment: .topLeading) {

                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        Color(
                            red: 0.1,
                            green: 0.1,
                            blue: 0.17
                        )
                    )
                    .overlay(
                        VStack(spacing: 0) {

                            ForEach(0..<12, id: \.self) { _ in

                                VStack(spacing: 0) {

                                    Spacer()

                                    Rectangle()
                                        .fill(.white.opacity(0.05))
                                        .frame(height: 0.5)
                                }
                                .frame(height: 28)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    )

                let recent = noteStore.notes(for: "Work")

                if recent.isEmpty {

                    Text("Start typing...")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white.opacity(0.18))
                        .padding(20)

                } else {

                    VStack(alignment: .leading, spacing: 16) {

                        ForEach(recent.prefix(3)) { note in

                            Button {

                                editingNote = note
                                showNoteEditor = true

                            } label: {

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {

                                    Text(
                                        note.title.isEmpty
                                        ? "Untitled"
                                        : note.title
                                    )
                                    .font(
                                        .system(
                                            size: 14,
                                            weight: .semibold,
                                            design: .rounded
                                        )
                                    )
                                    .foregroundColor(.white)

                                    Text(note.content)
                                        .font(
                                            .system(
                                                size: 12,
                                                design: .rounded
                                            )
                                        )
                                        .foregroundColor(
                                            .white.opacity(0.45)
                                        )
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 340)
            .padding(.horizontal, 20)

            Spacer()
        }
    }

    private func addTask() {

        let trimmedTask =
            newTask.trimmingCharacters(in: .whitespaces)

        guard !trimmedTask.isEmpty else {
            return
        }

        withAnimation {
            tasks.insert(trimmedTask, at: 0)
        }

        if showDatePicker {

            NotificationManager.shared.scheduleTaskReminder(
                task: trimmedTask,
                at: reminderDate,
                section: "Work"
            )

            showDatePicker = false
        }

        newTask = ""
    }
}

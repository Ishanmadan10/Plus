import SwiftUI

struct GenericSectionView: View {

    let sectionName: String
    let sectionIcon: String
    let sectionColor: String

    @Binding var tasks: [String]

    @ObservedObject var noteStore: NoteStore

    var onDismiss: () -> Void

    @State private var selectedTab: SectionTab = .checklist

    @State private var showNotesList = false
    @State private var showNoteEditor = false

    @State private var editingNote: Note? = nil

    var accentColor: Color {
        Color(hex: sectionColor)
    }

    var body: some View {

        ZStack {

            Color(
                red: 0.08,
                green: 0.08,
                blue: 0.14
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                SectionHeader(
                    icon: sectionIcon,
                    title: sectionName,
                    accentColor: accentColor,
                    onDismiss: onDismiss
                )

                HStack(spacing: 8) {

                    TabPill(
                        title: "Checklist",
                        icon: "checklist",
                        isSelected: selectedTab == .checklist,
                        accent: accentColor
                    ) {
                        selectedTab = .checklist
                    }

                    TabPill(
                        title: "Notes",
                        icon: "note.text",
                        isSelected: selectedTab == .notes,
                        accent: accentColor
                    ) {
                        selectedTab = .notes
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                if selectedTab == .checklist {

                    GenericChecklistTab(
                        tasks: $tasks,
                        accentColor: accentColor,
                        sectionName: sectionName
                    )

                } else {

                    GenericNotesTab(
                        sectionName: sectionName,
                        accentColor: accentColor,
                        noteStore: noteStore,
                        showNotesList: $showNotesList,
                        showNoteEditor: $showNoteEditor,
                        editingNote: $editingNote
                    )
                }
            }

            if showNotesList {

                NotesListView(
                    sectionName: sectionName,
                    accentColor: accentColor,
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

            if showNoteEditor {

                NoteEditorView(
                    sectionName: sectionName,
                    accentColor: accentColor,
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
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.85),
            value: showNotesList
        )
        .animation(
            .spring(response: 0.35, dampingFraction: 0.85),
            value: showNoteEditor
        )
    }
}

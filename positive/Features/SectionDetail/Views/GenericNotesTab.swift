import SwiftUI

struct GenericNotesTab: View {

    let sectionName: String
    let accentColor: Color

    @ObservedObject var noteStore: NoteStore

    @Binding var showNotesList: Bool
    @Binding var showNoteEditor: Bool

    @Binding var editingNote: Note?

    @State private var dragOffset: CGFloat = 0

    var body: some View {

        VStack(spacing: 12) {

            // Drag handle
            Capsule()
                .fill(.white.opacity(0.2))
                .frame(width: 42, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 8)

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
                    .background(accentColor.opacity(0.3))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                accentColor.opacity(0.5),
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

            let recentNotes = noteStore.notes(for: sectionName)

            if recentNotes.isEmpty {

                EmptyNotesView()

            } else {

                ScrollView {

                    VStack(spacing: 10) {

                        ForEach(recentNotes.prefix(5)) { note in

                            RecentNoteCard(
                                note: note,
                                onTap: {
                                    editingNote = note
                                    showNoteEditor = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in

                    if value.translation.height > 120 {

                        withAnimation(.spring()) {

                            showNotesList = false
                            showNoteEditor = false
                        }
                    }

                    withAnimation(.spring()) {
                        dragOffset = 0
                    }
                }
        )
        .animation(
            .spring(response: 0.35, dampingFraction: 0.85),
            value: dragOffset
        )
    }
}

import SwiftUI

struct NoteEditorView: View {

    let sectionName: String
    let accentColor: Color

    @ObservedObject var noteStore: NoteStore

    var existingNote: Note?
    var onDismiss: () -> Void

    @State private var title = ""
    @State private var content = ""

    @FocusState private var contentFocused: Bool

    var body: some View {

        ZStack {

            Color(
                red: 0.08,
                green: 0.08,
                blue: 0.14
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                HStack {

                    Button(action: onDismiss) {

                        Image(systemName: "chevron.down")
                            .font(
                                .system(
                                    size: 18,
                                    weight: .semibold
                                )
                            )
                            .foregroundColor(
                                .white.opacity(0.8)
                            )
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(
                        existingNote == nil
                        ? "New Note"
                        : "Edit Note"
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.white)

                    Spacer()

                    Button {

                        saveNote()
                        onDismiss()

                    } label: {

                        Text("Save")
                            .font(
                                .system(
                                    size: 15,
                                    weight: .semibold,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(accentColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                accentColor.opacity(0.15)
                            )
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)

                TextField("Title", text: $title)
                    .font(
                        .system(
                            size: 22,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                Divider()
                    .background(.white.opacity(0.1))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                ZStack(alignment: .topLeading) {

                    GeometryReader { geometry in

                        let lineHeight: CGFloat = 28

                        let lineCount =
                            Int(
                                geometry.size.height
                                / lineHeight
                            ) + 1

                        VStack(spacing: 0) {

                            ForEach(0..<lineCount, id: \.self) { _ in

                                VStack(spacing: 0) {

                                    Spacer()

                                    Rectangle()
                                        .fill(
                                            .white.opacity(0.06)
                                        )
                                        .frame(height: 0.5)
                                }
                                .frame(height: lineHeight)
                            }
                        }
                    }

                    TextEditor(text: $content)
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .foregroundColor(
                            .white.opacity(0.85)
                        )
                        .font(
                            .system(
                                size: 16,
                                design: .rounded
                            )
                        )
                        .lineSpacing(12)
                        .padding(.horizontal, 20)
                        .focused($contentFocused)

                    if content.isEmpty {

                        Text("Start writing...")
                            .font(
                                .system(
                                    size: 16,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(
                                .white.opacity(0.2)
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }

                Spacer()
            }
        }
        .onAppear {

            if let note = existingNote {

                title = note.title
                content = note.content
            }

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.5
            ) {

                contentFocused = true
            }
        }
    }

    private func saveNote() {

        let trimmedTitle =
            title.trimmingCharacters(in: .whitespaces)

        let trimmedContent =
            content.trimmingCharacters(in: .whitespaces)

        guard
            !trimmedTitle.isEmpty
            || !trimmedContent.isEmpty
        else {
            return
        }

        var note =
            existingNote
            ?? Note(
                title:
                    trimmedTitle.isEmpty
                    ? "Untitled"
                    : trimmedTitle,
                content: trimmedContent,
                sectionName: sectionName
            )

        note.title =
            trimmedTitle.isEmpty
            ? "Untitled"
            : trimmedTitle

        note.content = trimmedContent

        noteStore.save(note: note)
    }
}

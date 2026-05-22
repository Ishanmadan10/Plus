import SwiftUI

struct NotesListView: View {

    let sectionName: String
    let accentColor: Color

    @ObservedObject var noteStore: NoteStore

    var onSelect: (Note) -> Void
    var onDismiss: () -> Void

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

                    Text("\\(sectionName) Notes")
                        .font(
                            .system(
                                size: 20,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.white)

                    Spacer()

                    Circle()
                        .fill(.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)

                let notes =
                    noteStore.notes(for: sectionName)

                if notes.isEmpty {

                    Spacer()

                    VStack(spacing: 12) {

                        Image(systemName: "note.text")
                            .font(
                                .system(
                                    size: 44,
                                    weight: .light
                                )
                            )
                            .foregroundColor(
                                .white.opacity(0.15)
                            )

                        Text("No notes yet")
                            .font(
                                .system(
                                    size: 16,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(
                                .white.opacity(0.3)
                            )
                    }

                    Spacer()

                } else {

                    ScrollView {

                        VStack(spacing: 10) {

                            ForEach(notes) { note in

                                Button {

                                    onSelect(note)

                                } label: {

                                    HStack(alignment: .top) {

                                        VStack(
                                            alignment: .leading,
                                            spacing: 6
                                        ) {

                                            Text(
                                                note.title.isEmpty
                                                ? "Untitled"
                                                : note.title
                                            )
                                            .font(
                                                .system(
                                                    size: 16,
                                                    weight: .medium,
                                                    design: .rounded
                                                )
                                            )
                                            .foregroundColor(.white)
                                            .lineLimit(1)

                                            Text(
                                                note.content.isEmpty
                                                ? "No content"
                                                : note.content
                                            )
                                            .font(
                                                .system(
                                                    size: 13,
                                                    design: .rounded
                                                )
                                            )
                                            .foregroundColor(
                                                .white.opacity(0.4)
                                            )
                                            .lineLimit(2)

                                            Text(note.formattedDate)
                                                .font(
                                                    .system(
                                                        size: 11,
                                                        design: .rounded
                                                    )
                                                )
                                                .foregroundColor(
                                                    accentColor.opacity(0.7)
                                                )
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13))
                                            .foregroundColor(
                                                .white.opacity(0.2)
                                            )
                                    }
                                    .padding(16)
                                    .background(
                                        .white.opacity(0.07)
                                    )
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(
                                            cornerRadius: 16
                                        )
                                        .stroke(
                                            .white.opacity(0.08),
                                            lineWidth: 1
                                        )
                                    )
                                }
                                .contextMenu {

                                    Button(
                                        role: .destructive
                                    ) {

                                        noteStore.delete(note)

                                    } label: {

                                        Label(
                                            "Delete",
                                            systemImage: "trash"
                                        )
                                    }
                                }
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

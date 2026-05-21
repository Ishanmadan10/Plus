import SwiftUI
import PhotosUI

struct JournalSectionView: View {

    let sectionColor: String
    @ObservedObject var noteStore: NoteStore
    var onDismiss: () -> Void

    @State private var entryText = ""
    @State private var selectedColor: Color = .white
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    @State private var currentNoteID: UUID = UUID()

    @State private var dragOffset: CGFloat = 0

    @FocusState private var focused: Bool

    let textColors: [(Color, String)] = [
        (.white, "FFFFFF"),
        (.yellow, "FFD60A"),
        (Color(hex: "FF6B6B"), "FF6B6B"),
        (Color(hex: "69DB7C"), "69DB7C")
    ]

    var accent: Color {
        Color(hex: sectionColor)
    }

    private var dateLabel: String {

        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"

        return f.string(from: Date()).uppercased()
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

                // DRAG HANDLE

                Capsule()
                    .fill(.white.opacity(0.22))
                    .frame(width: 42, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 8)

                SectionHeader(
                    icon: "notebook",
                    title: "Journal",
                    accentColor: accent,
                    trailing: AnyView(EmptyView()),
                    onDismiss: onDismiss
                )

                Text(dateLabel)
                    .font(
                        .system(
                            size: 11,
                            weight: .medium,
                            design: .rounded
                        )
                    )
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.35))
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                JournalEditorView(
                    entryText: $entryText,
                    selectedColor: $selectedColor,
                    selectedImage: $selectedImage,
                    focused: _focused,
                    onDeleteImage: deleteImage
                )

                if !focused {

                    JournalToolbar(
                        accent: accent,
                        photoItem: $photoItem,
                        selectedImage: $selectedImage,
                        entryText: $entryText,
                        selectedColor: $selectedColor,
                        textColors: textColors
                    )
                    .padding(.bottom, 8)
                }
            }
            .offset(y: dragOffset)

            // FIXED SWIPE DOWN

            .highPriorityGesture(

                DragGesture()

                    .onChanged { value in

                        if value.translation.height > 0 {

                            dragOffset = value.translation.height
                        }
                    }

                    .onEnded { value in

                        if value.translation.height > 120 {

                            withAnimation(.spring()) {

                                onDismiss()
                            }

                        } else {

                            withAnimation(.spring()) {

                                dragOffset = 0
                            }
                        }
                    }
            )

            .onTapGesture {

                focused = false
            }
        }

        .overlay(alignment: .bottom) {

            if focused {

                JournalToolbar(
                    accent: accent,
                    photoItem: $photoItem,
                    selectedImage: $selectedImage,
                    entryText: $entryText,
                    selectedColor: $selectedColor,
                    textColors: textColors
                )
                .background(
                    Color(
                        red: 0.08,
                        green: 0.08,
                        blue: 0.14
                    )
                )
            }
        }

        .animation(
            .spring(
                response: 0.3,
                dampingFraction: 0.8
            ),
            value: focused
        )

        .ignoresSafeArea(
            .keyboard,
            edges: .bottom
        )

        .onAppear {

            dragOffset = 0
            loadTodayEntry()
        }

        // AUTO SAVE TEXT

        .onChange(of: entryText) {

            autoSave()
        }

        // AUTO SAVE IMAGE

        .onChange(of: photoItem) {

            Task {

                if let data = try? await photoItem?
                    .loadTransferable(type: Data.self),

                   let img = UIImage(data: data) {

                    selectedImage = img

                    saveImage(img)

                    autoSave()
                }
            }
        }
    }

    // MARK: LOAD

    private func loadTodayEntry() {

        let entries = noteStore.notes(for: "Journal")

        if let today = entries.first(
            where: { $0.title == dateLabel }
        ) {

            currentNoteID = today.id
            entryText = today.content
        }

        selectedImage = loadImage(for: dateLabel)
    }

    // MARK: AUTO SAVE

    private func autoSave() {

        let note = Note(
            id: currentNoteID,
            title: dateLabel,
            content: entryText,
            sectionName: "Journal"
        )

        currentNoteID = note.id

        noteStore.save(note: note)
    }

    // MARK: IMAGE

    private func imageURL(
        for dateLabel: String
    ) -> URL {

        let docs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let safe = dateLabel.replacingOccurrences(
            of: " ",
            with: "_"
        )

        return docs.appendingPathComponent(
            "journal_img_\(safe).jpg"
        )
    }

    private func saveImage(
        _ image: UIImage
    ) {

        if let data = image.jpegData(
            compressionQuality: 0.85
        ) {

            try? data.write(
                to: imageURL(for: dateLabel)
            )
        }
    }

    private func loadImage(
        for dateLabel: String
    ) -> UIImage? {

        let url = imageURL(for: dateLabel)

        guard let data = try? Data(contentsOf: url)
        else {
            return nil
        }

        return UIImage(data: data)
    }

    private func deleteImage() {

        selectedImage = nil

        try? FileManager.default.removeItem(
            at: imageURL(for: dateLabel)
        )
    }
}

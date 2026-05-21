import SwiftUI

struct RecentNoteCard: View {

    let note: Note

    let onTap: () -> Void

    var body: some View {

        Button(action: onTap) {

            HStack(alignment: .top, spacing: 12) {

                VStack(alignment: .leading, spacing: 4) {

                    Text(
                        note.title.isEmpty
                        ? "Untitled"
                        : note.title
                    )
                    .font(
                        .system(
                            size: 15,
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
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(2)
                }

                Spacer()

                Text(note.formattedDate)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(14)
            .background(.white.opacity(0.07))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

import SwiftUI

struct EmptyNotesView: View {

    var body: some View {

        VStack(spacing: 16) {

            Spacer()

            Image(systemName: "note.text")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white.opacity(0.15))

            Text("No notes yet")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.white.opacity(0.25))

            Spacer()
        }
    }
}

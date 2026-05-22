import SwiftUI

struct JournalEditorView: View {
    @Binding var entryText: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                if entryText.isEmpty {
                    Text("What's on your mind today?")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .accessibilityLabel("Journal entry placeholder")
                }
                TextEditor(text: $entryText)
                    .frame(minHeight: 150)
                    .scrollContentBackground(.hidden) // Hide default scroll background
                    .background(Color.clear) // Ensure TextEditor background is clear
                    .padding(.horizontal, 0)
                    .padding(.vertical, 0)
                    .accessibilityLabel("Journal entry text editor")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .accessibilityLabel("Cancel journal entry")

                Spacer()

                Button("Save") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Save journal entry")
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

struct JournalEditorView_Previews: PreviewProvider {
    @State static var text: String = ""
    static var previews: some View {
        JournalEditorView(entryText: $text, onSave: {}, onCancel: {})
            .preferredColorScheme(.dark)
    }
}

import SwiftUI

struct QuickInputOverlay: View {

    let title: String
    let placeholder: String
    let accent: Color

    @Binding var value: String

    let onSave: () -> Void
    let onCancel: () -> Void

    @FocusState private var focused: Bool

    var body: some View {

        ZStack {

            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            VStack(spacing: 16) {

                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                TextField(placeholder, text: $value)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.1))
                    .cornerRadius(14)
                    .foregroundColor(.white)
                    .font(.system(size: 15, design: .rounded))
                    .focused($focused)
                    .onSubmit {
                        onSave()
                    }

                HStack(spacing: 12) {

                    Button(action: onCancel) {

                        Text("Cancel")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.08))
                            .cornerRadius(14)
                    }

                    Button(action: onSave) {

                        Text("Add")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(accent.opacity(0.85))
                            .cornerRadius(14)
                    }
                    .disabled(
                        value.trimmingCharacters(in: .whitespaces).isEmpty
                    )
                }
            }
            .padding(24)
            .background(Color(red: 0.12, green: 0.10, blue: 0.18))
            .cornerRadius(24)
            .padding(.horizontal, 30)
        }
        .onAppear {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focused = true
            }
        }
    }
}

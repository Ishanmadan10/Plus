import SwiftUI

struct JournalEditorView: View {

    @Binding var entryText: String
    @Binding var selectedColor: Color
    @Binding var selectedImage: UIImage?

    @FocusState var focused: Bool

    var onDeleteImage: () -> Void

    var body: some View {

        ZStack(alignment: .topLeading) {

            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.17))

            GeometryReader { geo in

                let lineH: CGFloat = 28
                let count = Int(geo.size.height / lineH) + 1

                VStack(spacing: 0) {

                    ForEach(0..<count, id: \.self) { _ in

                        VStack(spacing: 0) {

                            Spacer()

                            Rectangle()
                                .fill(.white.opacity(0.06))
                                .frame(height: 0.5)
                        }
                        .frame(height: lineH)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            ScrollView {

                VStack(alignment: .leading, spacing: 16) {

                    // IMAGE
                    if let img = selectedImage {

                        ZStack(alignment: .topTrailing) {

                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(14)

                            Button {

                                onDeleteImage()

                            } label: {

                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                    }

                    // EDITABLE TEXT
                    TextEditor(text: $entryText)
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .foregroundColor(selectedColor)
                        .font(.system(size: 15, design: .rounded))
                        .lineSpacing(14)
                        .focused($focused)
                        .frame(minHeight: 500)
                        .padding(.horizontal, 16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
}

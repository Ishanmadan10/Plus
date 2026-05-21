import SwiftUI
import PhotosUI

struct JournalToolbar: View {

    let accent: Color

    @Binding var photoItem: PhotosPickerItem?
    @Binding var selectedImage: UIImage?
    @Binding var entryText: String
    @Binding var selectedColor: Color

    let textColors: [(Color, String)]

    var body: some View {

        HStack(spacing: 12) {

            PhotosPicker(
                selection: $photoItem,
                matching: .images
            ) {

                HStack(spacing: 5) {

                    Image(systemName: "photo")
                        .font(.system(size: 13))

                    Text("Photo")
                        .font(.system(size: 12, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.55))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.08))
                .cornerRadius(20)
            }

            Menu {

                ForEach(
                    ["😊", "😐", "😔", "😤", "🥰", "😴"],
                    id: \.self
                ) { emoji in

                    Button(emoji) {
                        entryText += " \(emoji)"
                    }
                }

            } label: {

                HStack(spacing: 5) {

                    Text("☺")
                        .font(.system(size: 13))

                    Text("Mood")
                        .font(.system(size: 12, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.55))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.08))
                .cornerRadius(20)
            }

            Menu {

                ForEach(textColors, id: \.1) { (col, _) in

                    Button {

                        selectedColor = col

                    } label: {

                        Label(
                            "",
                            systemImage: "circle.fill"
                        )
                        .tint(col)
                    }
                }

            } label: {

                HStack(spacing: 5) {

                    Circle()
                        .fill(selectedColor)
                        .frame(width: 10, height: 10)

                    Text("Colour")
                        .font(.system(size: 12, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.55))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.08))
                .cornerRadius(20)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.white.opacity(0.03))
    }
}

import SwiftUI

struct SectionHeader: View {

    let icon: String
    let title: String
    let accentColor: Color

    var trailing: AnyView? = nil

    let onDismiss: () -> Void

    var body: some View {

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

            HStack(spacing: 8) {

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(accentColor)

                Text(title)
                    .font(
                        .system(
                            size: 24,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.white)
            }

            Spacer()

            if let trailing {

                trailing

            } else {

                Circle()
                    .fill(.clear)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
    }
}

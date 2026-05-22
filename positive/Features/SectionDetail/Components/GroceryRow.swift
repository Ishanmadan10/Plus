import SwiftUI

struct GroceryRow: View {
    @Binding var item: GroceryItem

    let accent: Color
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showDelete = false

    var body: some View {

        ZStack(alignment: .trailing) {

            Button(action: onDelete) {

                ZStack {

                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.75))

                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(width: 66)
            }
            .opacity(showDelete ? 1 : 0)

            HStack(spacing: 12) {

                Button {

                    if !showDelete {
                        onSelect()
                    }

                } label: {

                    ZStack {

                        Circle()
                            .fill(
                                isSelected
                                ? accent.opacity(0.85)
                                : .clear
                            )
                            .frame(width: 24, height: 24)

                        Circle()
                            .strokeBorder(
                                isSelected
                                ? accent
                                : .white.opacity(0.3),
                                lineWidth: 1.5
                            )
                            .frame(width: 24, height: 24)

                        if isSelected {

                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                        }
                    }
                }

                Text(item.name)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(
                        isSelected
                        ? accent
                        : .white
                    )
                    .fontWeight(
                        isSelected
                        ? .semibold
                        : .regular
                    )

                Spacer()

                if isSelected {

                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(accent.opacity(0.7))
                        .transition(
                            .scale.combined(with: .opacity)
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                isSelected
                ? accent.opacity(0.1)
                : .white.opacity(0.07)
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected
                        ? accent.opacity(0.5)
                        : .white.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .offset(x: offset)
            .gesture(
                DragGesture()

                    .onChanged { value in

                        if value.translation.width < 0 {

                            offset = max(
                                value.translation.width,
                                -76
                            )
                        }
                    }

                    .onEnded { value in

                        withAnimation(.spring()) {

                            if value.translation.width < -46 {

                                offset = -76
                                showDelete = true

                            } else {

                                offset = 0
                                showDelete = false
                            }
                        }
                    }
            )
            .onTapGesture {

                if showDelete {

                    withAnimation {

                        offset = 0
                        showDelete = false
                    }

                } else {

                    onSelect()
                }
            }
        }
    }
}

import SwiftUI

struct PrayerCardRow: View {

    @Binding var prayer: PrayerCard
    let accent: Color
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showDelete = false

    var body: some View {

        ZStack(alignment: .trailing) {

            // Swipe-to-delete background
            Button(action: onDelete) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.red.opacity(0.75))
                    Image(systemName: "trash")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .frame(width: 66)
            }
            .opacity(showDelete ? 1 : 0)

            HStack(spacing: 14) {

                // Checkbox
                Button {
                    withAnimation(.spring()) { prayer.isCompleted.toggle() }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(prayer.isCompleted ? accent.opacity(0.85) : .clear)
                            .frame(width: 28, height: 28)
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                prayer.isCompleted ? accent : .white.opacity(0.3),
                                lineWidth: 1.5
                            )
                            .frame(width: 28, height: 28)
                        if prayer.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(prayer.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(prayer.isCompleted ? .white.opacity(0.4) : .white)

                    HStack(spacing: 8) {
                        if !prayer.frequency.isEmpty {
                            Text(prayer.frequency)
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(accent.opacity(0.85))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(accent.opacity(0.15))
                                .cornerRadius(8)
                        }
                        if let t = prayer.time, !t.isEmpty {
                            Text(t)
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(.white.opacity(0.45))
                        }
                    }
                }

                Spacer()

                Image(systemName: prayer.icon)
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(accent.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(.white.opacity(0.07))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(accent.opacity(0.15), lineWidth: 1)
            )
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { v in
                        if v.translation.width < 0 {
                            offset = max(v.translation.width, -76)
                        }
                    }
                    .onEnded { v in
                        withAnimation(.spring()) {
                            if v.translation.width < -46 {
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
                    withAnimation { offset = 0; showDelete = false }
                }
            }
        }
    }
}

import SwiftUI

struct TaskRow: View {

    let task: String
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showDelete = false

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: onDelete) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.red.opacity(0.75))
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(width: 72)
            }
            .opacity(showDelete ? 1 : 0)

            HStack {
                Image(systemName: "circle")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.5))
                Text(task)
                    .foregroundColor(.white)
                    .font(.system(size: 16, design: .rounded))
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(.white.opacity(0.1))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.15), lineWidth: 1))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -80)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if value.translation.width < -50 {
                                offset = -80
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
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = 0
                        showDelete = false
                    }
                }
            }
        }
    }
}

import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [String]

    var body: some View {
        GeometryReader { geo in
            if tasks.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "checklist")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                        .accessibilityHidden(true)
                    Text("No tasks added yet. Use the field below to add one.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .accessibilityLabel("No tasks added yet. Use the field below to add one.")
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(tasks.indices, id: \.self) {
                            index in
                            TaskRow(task: tasks[index]) {
                                tasks.remove(at: index)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .frame(width: geo.size.width)
            }
        }
    }
}

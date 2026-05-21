import SwiftUI

struct TaskListView: View {
    @Binding var tasks: [String]

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(tasks.indices, id: \.self) { index in
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

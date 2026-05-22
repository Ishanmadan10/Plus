import SwiftUI

struct GenericChecklistTab: View {

    @Binding var tasks: [String]

    let accentColor: Color
    let sectionName: String

    @State private var newTask = ""

    @State private var showDatePicker = false

    @State private var reminderDate =
        Calendar.current.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: Date()
        ) ?? Date()

    var body: some View {

        VStack(spacing: 0) {

            Text("Swipe left to delete")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.white.opacity(0.25))
                .padding(.bottom, 10)

            TaskListView(tasks: $tasks)

            if showDatePicker {

                ReminderDatePicker(
                    accentColor: accentColor,
                    reminderDate: $reminderDate,
                    showDatePicker: $showDatePicker
                )
                .transition(
                    .move(edge: .bottom)
                    .combined(with: .opacity)
                )
            }

            HStack(spacing: 10) {

                TextField("Add a task...", text: $newTask)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.08))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 16, design: .rounded))
                    .onSubmit {
                        addTask()
                    }

                Button {

                    withAnimation {
                        showDatePicker.toggle()
                    }

                } label: {

                    Image(systemName: showDatePicker ? "bell.fill" : "bell")
                        .font(.system(size: 20))
                        .foregroundColor(
                            showDatePicker
                            ? accentColor
                            : .white.opacity(0.4)
                        )
                }

                Button(action: addTask) {

                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(accentColor)
                }
                .disabled(
                    newTask
                        .trimmingCharacters(in: .whitespaces)
                        .isEmpty
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.white.opacity(0.03))
        }
    }

    private func addTask() {

        let trimmed =
            newTask.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            return
        }

        withAnimation {
            tasks.insert(trimmed, at: 0)
        }

        if showDatePicker {

            NotificationManager.shared.scheduleTaskReminder(
                task: trimmed,
                at: reminderDate,
                section: sectionName
            )

            showDatePicker = false
        }

        newTask = ""
    }
}

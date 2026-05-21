import SwiftUI

struct ReminderDatePicker: View {

    let accentColor: Color

    @Binding var reminderDate: Date
    @Binding var showDatePicker: Bool

    var body: some View {

        VStack(spacing: 10) {

            HStack {

                Image(systemName: "bell.fill")
                    .font(.system(size: 13))
                    .foregroundColor(accentColor)

                Text("Remind me at")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                Button {

                    withAnimation {
                        showDatePicker = false
                    }

                } label: {

                    Image(systemName: "xmark")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            DatePicker(
                "",
                selection: $reminderDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .colorScheme(.dark)
            .labelsHidden()
            .padding(.horizontal, 20)
        }
    }
}

import SwiftUI

struct AddPrayerView: View {

    let accent: Color
    let onAdd: (PrayerCard) -> Void

    @State private var newName = ""
    @State private var newFreq = "1× daily"
    @State private var newTime = ""

    let freqOptions = [
        "1× daily",
        "2× daily",
        "3× daily",
        "Weekly"
    ]

    var body: some View {

        VStack(spacing: 12) {

            TextField("Prayer / practice name...", text: $newName)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white.opacity(0.08))
                .cornerRadius(14)
                .foregroundColor(.white)
                .font(.system(size: 14, design: .rounded))

            // Frequency picker
            HStack(spacing: 8) {
                ForEach(freqOptions, id: \.self) { opt in
                    Button { newFreq = opt } label: {
                        Text(opt)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(newFreq == opt ? .white : .white.opacity(0.4))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                newFreq == opt
                                ? accent.opacity(0.5)
                                : Color.white.opacity(0.06)
                            )
                            .cornerRadius(10)
                    }
                }
            }

            // Time + Add button
            HStack {
                TextField("Time (e.g. 7 AM)", text: $newTime)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.08))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .font(.system(size: 13, design: .rounded))

                Button {
                    let n = newName.trimmingCharacters(in: .whitespaces)
                    guard !n.isEmpty else { return }
                    onAdd(PrayerCard(
                        name: n,
                        subtitle: "",
                        frequency: newFreq,
                        time: newTime.isEmpty ? nil : newTime
                    ))
                    newName = ""
                    newTime = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(accent)
                }
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

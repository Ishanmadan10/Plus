import SwiftUI

struct GroceriesSectionView: View {

    let sectionColor: String
    var onDismiss: () -> Void

    @State private var items: [GroceryItem] = [
        GroceryItem(name: "Milk x2"),
        GroceryItem(name: "Bananas"),
        GroceryItem(name: "Protein powder"),
        GroceryItem(name: "Eggs x12")
    ]

    @State private var newItem = ""

    @State private var selectedItemID: UUID? = nil

    var accent: Color {
        Color(hex: sectionColor)
    }

    var body: some View {

        ZStack {

            Color(
                red: 0.07,
                green: 0.12,
                blue: 0.10
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                SectionHeader(
                    icon: "cart",
                    title: "Groceries",
                    accentColor: accent,
                    trailing: AnyView(
                        Button {

                            withAnimation {

                                items.removeAll()
                                selectedItemID = nil
                            }

                        } label: {

                            Image(systemName: "trash")
                                .font(.system(size: 15))
                                .foregroundColor(
                                    .white.opacity(0.4)
                                )
                                .padding(12)
                                .background(
                                    .white.opacity(0.08)
                                )
                                .clipShape(Circle())
                        }
                    ),
                    onDismiss: onDismiss
                )

                Text("Tap to select · Swipe left to delete")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.25))
                    .padding(.bottom, 10)

                ScrollView {

                    LazyVStack(spacing: 10) {

                        ForEach($items) { $item in

                            GroceryRow(
                                item: $item,
                                accent: accent,
                                isSelected:
                                    selectedItemID == item.id,
                                onSelect: {

                                    withAnimation(
                                        .spring(
                                            response: 0.3,
                                            dampingFraction: 0.75
                                        )
                                    ) {

                                        selectedItemID =
                                            (selectedItemID == item.id)
                                            ? nil
                                            : item.id
                                    }
                                },
                                onDelete: {

                                    withAnimation {

                                        if selectedItemID == item.id {

                                            selectedItemID = nil
                                        }

                                        items.removeAll {
                                            $0.id == item.id
                                        }
                                    }
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 12)
                }

                HStack(spacing: 10) {

                    Button {
                        openBlinkit()
                    } label: {

                        HStack(spacing: 8) {

                            Image(systemName: "cart.fill")
                                .font(.system(size: 14))

                            Text("Open Blinkit")
                                .font(
                                    .system(
                                        size: 13,
                                        weight: .semibold,
                                        design: .rounded
                                    )
                                )
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            selectedItemID != nil
                            ? Color(hex: "F8CB2E").opacity(0.9)
                            : Color(hex: "F8CB2E").opacity(0.35)
                        )
                        .cornerRadius(16)
                    }
                    .disabled(selectedItemID == nil)

                    Button {

                        openApp(
                            scheme: "zepto://",
                            fallback: "https://www.zeptonow.com"
                        )

                    } label: {

                        HStack(spacing: 8) {

                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14))

                            Text("Open Zepto")
                                .font(
                                    .system(
                                        size: 13,
                                        weight: .semibold,
                                        design: .rounded
                                    )
                                )
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            Color(hex: "8B2FC9").opacity(0.9)
                        )
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)

                if let id = selectedItemID,
                   let item = items.first(where: { $0.id == id }) {

                    Text(
                        "Blinkit will search: \"\(item.name)\""
                    )
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(accent.opacity(0.8))
                    .padding(.bottom, 4)
                    .transition(
                        .opacity.combined(
                            with: .scale(scale: 0.95)
                        )
                    )

                } else {

                    Text(
                        "Tap an item to select it for Blinkit search"
                    )
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 4)
                }

                HStack(spacing: 10) {

                    TextField("Add item...", text: $newItem)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.07))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    .white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                        .foregroundColor(.white)
                        .font(
                            .system(size: 15, design: .rounded)
                        )
                        .onSubmit {
                            addItem()
                        }

                    Button(action: addItem) {

                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(accent)
                    }
                    .disabled(
                        newItem
                            .trimmingCharacters(
                                in: .whitespaces
                            )
                            .isEmpty
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .animation(
            .spring(response: 0.3, dampingFraction: 0.8),
            value: selectedItemID
        )
    }

    private func addItem() {

        let trimmed =
            newItem.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            return
        }

        withAnimation {

            items.insert(
                GroceryItem(name: trimmed),
                at: 0
            )
        }

        newItem = ""
    }

    private func openBlinkit() {

        guard let id = selectedItemID,
              let item = items.first(where: { $0.id == id })
        else {
            return
        }

        let query =
            item.name
                .replacingOccurrences(
                    of: #"\\s*x\\d+"#,
                    with: "",
                    options: .regularExpression
                )
                .trimmingCharacters(in: .whitespaces)

        let encoded =
            query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ) ?? ""

        if let url = URL(
            string: "https://blinkit.com/s/?q=\(encoded)"
        ) {

            UIApplication.shared.open(url)
        }
    }

    private func openApp(
        scheme: String,
        fallback: String
    ) {

        if let url = URL(string: scheme),
           UIApplication.shared.canOpenURL(url) {

            UIApplication.shared.open(url)

        } else if let url = URL(string: fallback) {

            UIApplication.shared.open(url)
        }
    }
}

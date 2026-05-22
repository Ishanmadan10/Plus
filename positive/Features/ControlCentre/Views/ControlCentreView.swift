import SwiftUI

struct ControlCentreView: View {

    @ObservedObject var sectionStore: SectionStore
    @ObservedObject var vm: HomeViewModel
    var onDismiss: () -> Void
    var onSelectSection: (AppSection) -> Void

    @State private var isEditing = false
    @State private var showAddSection = false
    @State private var newTitle = ""
    @State private var newIcon = "star"
    @State private var newColor = "9B7FD4"

    let iconOptions = [
        "briefcase", "cart", "figure.run", "lightbulb", "bell",
        "notebook", "sparkles", "person", "heart", "book",
        "music.note", "camera", "airplane", "bicycle", "leaf"
    ]

    let colorOptions = [
        "4A90D9", "4CAF50", "E57373", "FFB74D",
        "BA68C8", "F06292", "80CBC4", "A1887F",
        "9B7FD4", "FF8A65", "4DB6AC", "DCE775"
    ]

    var body: some View {
        ZStack {

            // Dark dimmed background — fixes visibility issue
            Rectangle()
                .fill(.black.opacity(0.75))
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {

                // Header
                HStack {
                    Button { onDismiss() } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(.white.opacity(0.12))
                            .clipShape(Circle())
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("MY SPACE")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1.5)
                        Text("Sections")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isEditing.toggle()
                        }
                    } label: {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 24)

                // Section Grid
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 14
                    ) {
                        ForEach(sectionStore.sections) { section in
                            SectionCard(
                                section: section,
                                taskCount: vm.allTasks[section.title]?.count ?? 0,
                                isEditing: isEditing,
                                onTap: { onSelectSection(section) },
                                onDelete: {
                                    withAnimation {
                                        sectionStore.delete(section)
                                    }
                                }
                            )
                        }

                        // Add new section button
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showAddSection = true
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.white.opacity(0.04))
                                    .frame(height: 110)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(.white.opacity(0.12), lineWidth: 1)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                                    .foregroundColor(.white.opacity(0.15))
                                            )
                                    )

                                VStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 22, weight: .light))
                                        .foregroundColor(.white.opacity(0.3))
                                    Text("Add section")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }

            // Add Section Sheet
            if showAddSection {
                AddSectionSheet(
                    iconOptions: iconOptions,
                    colorOptions: colorOptions,
                    onAdd: { title, icon, color in
                        sectionStore.add(title: title, icon: icon, colorHex: color)
                        showAddSection = false
                    },
                    onDismiss: { showAddSection = false }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(20)
            }
        }
    }
}

// MARK: - Section Card
private struct SectionCard: View {

    let section: AppSection
    let taskCount: Int
    let isEditing: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    var accentColor: Color { Color(hex: section.colorHex) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 0) {

                    // Dot + label at top
                    HStack(spacing: 5) {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 6, height: 6)
                        Text(section.title.uppercased())
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.45))
                            .tracking(0.8)
                    }

                    Spacer()

                    // Bold title
                    Text(section.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    // Subtitle
                    Text(taskCount == 0 ? "Empty" : "\(taskCount) item\(taskCount == 1 ? "" : "s")")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(accentColor.opacity(0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(accentColor.opacity(0.4), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            if isEditing {
                Button(action: onDelete) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.9))
                            .frame(width: 22, height: 22)
                        Image(systemName: "minus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 6, y: -6)
            }
        }
    }
}

// MARK: - Add Section Sheet
private struct AddSectionSheet: View {

    let iconOptions: [String]
    let colorOptions: [String]
    let onAdd: (String, String, String) -> Void
    let onDismiss: () -> Void

    @State private var title = ""
    @State private var selectedIcon = "star"
    @State private var selectedColor = "9B7FD4"

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.6))
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 20) {
                    Text("New Section")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    TextField("Section name...", text: $title)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.1))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                        .font(.system(size: 16, design: .rounded))

                    // Icon picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Icon")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(selectedIcon == icon ? .white : .white.opacity(0.35))
                                        .frame(width: 40, height: 40)
                                        .background(selectedIcon == icon
                                            ? Color(hex: selectedColor).opacity(0.4)
                                            : Color.white.opacity(0.06))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    // Color picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Color")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                            ForEach(colorOptions, id: \.self) { hex in
                                Button {
                                    selectedColor = hex
                                } label: {
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(.white, lineWidth: selectedColor == hex ? 2 : 0)
                                        )
                                }
                            }
                        }
                    }

                    Button {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        onAdd(title, selectedIcon, selectedColor)
                    } label: {
                        Text("Add Section")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: selectedColor).opacity(0.8))
                            .cornerRadius(18)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(24)
                .background(Color(red: 0.1, green: 0.1, blue: 0.18))
                .cornerRadius(32)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }
}

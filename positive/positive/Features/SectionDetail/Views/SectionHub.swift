import SwiftUI

struct AppSection: Identifiable, Codable {
    let id: UUID
    var title: String
    var icon: String
    var colorHex: String

    init(id: UUID = UUID(), title: String, icon: String, colorHex: String) {
        self.id = id
        self.title = title
        self.icon = icon
        self.colorHex = colorHex
    }
}

@MainActor
class SectionStore: ObservableObject {

    @Published var sections: [AppSection] = [] {
        didSet { save() }
    }

    private let key = "sections_v1"

    init() {
        load()
        if sections.isEmpty {
            sections = Self.defaults
        }
    }

    static let defaults: [AppSection] = [
        AppSection(title: "Work",        icon: "briefcase",    colorHex: "4A90D9"),
        AppSection(title: "Groceries",   icon: "cart",         colorHex: "4CAF50"),
        AppSection(title: "Gym",         icon: "figure.run",   colorHex: "E57373"),
        AppSection(title: "Ideas",       icon: "lightbulb",    colorHex: "FFB74D"),
        AppSection(title: "Reminders",   icon: "bell",         colorHex: "BA68C8"),
        AppSection(title: "Journal",     icon: "notebook",     colorHex: "F06292"),
        AppSection(title: "Spirituality",icon: "sparkles",     colorHex: "80CBC4"),
        AppSection(title: "Personal",    icon: "person",       colorHex: "A1887F"),
    ]

    func add(title: String, icon: String, colorHex: String) {
        let s = AppSection(title: title, icon: icon, colorHex: colorHex)
        sections.append(s)
    }

    func delete(_ section: AppSection) {
        sections.removeAll { $0.id == section.id }
    }

    // task counts
    func taskCount(for section: AppSection, allTasks: [String: [String]]) -> Int {
        allTasks[section.title]?.count ?? 0
    }

    private func save() {
        if let e = try? JSONEncoder().encode(sections) {
            UserDefaults.standard.set(e, forKey: key)
        }
    }

    private func load() {
        guard let d = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([AppSection].self, from: d)
        else { return }
        sections = decoded
    }
}

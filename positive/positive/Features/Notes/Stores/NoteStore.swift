import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var sectionName: String

    init(id: UUID = UUID(), title: String, content: String, sectionName: String) {
        self.id = id
        self.title = title
        self.content = content
        self.date = Date()
        self.sectionName = sectionName
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        return f.string(from: date)
    }
}

@MainActor
class NoteStore: ObservableObject {

    @Published var notes: [Note] = [] {
        didSet { save() }
    }

    private let key = "notes_store_v1"

    init() { load() }

    func notes(for section: String) -> [Note] {
        notes.filter { $0.sectionName == section }
            .sorted { $0.date > $1.date }
    }

    func save(note: Note) {
        if let i = notes.firstIndex(where: { $0.id == note.id }) {
            notes[i] = note
        } else {
            notes.insert(note, at: 0)
        }
    }

    func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
    }

    private func save() {
        if let e = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(e, forKey: key)
        }
    }

    private func load() {
        guard let d = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Note].self, from: d)
        else { return }
        notes = decoded
    }
}

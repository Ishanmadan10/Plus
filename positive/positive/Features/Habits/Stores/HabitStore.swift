import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    var title: String
    var completedDates: [String]

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
        self.completedDates = []
    }

    var isCompletedToday: Bool {
        completedDates.contains(Self.todayKey())
    }

    mutating func toggleToday() {
        let key = Self.todayKey()
        if completedDates.contains(key) {
            completedDates.removeAll { $0 == key }
        } else {
            completedDates.append(key)
        }
    }

    static func todayKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}

@MainActor
class HabitStore: ObservableObject {

    @Published var habits: [Habit] = [] {
        didSet { save() }
    }

    private let key = "habits_v1"

    init() {
        load()
        if habits.isEmpty {
            habits = [
                Habit(title: "Gym"),
                Habit(title: "Sleep by 12"),
                Habit(title: "Laundry"),
                Habit(title: "Read 10 pages"),
                Habit(title: "No phone after 11")
            ]
        }
    }

    func toggle(_ habit: Habit) {
        guard let i = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[i].toggleToday()
    }

    func add(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        habits.append(Habit(title: trimmed))
    }

    func delete(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
    }

    // MARK: - Calendar helpers

    // Returns completion ratio (0.0 – 1.0) for a given date string
    func completionRatio(for dateKey: String) -> Double {
        guard !habits.isEmpty else { return 0 }
        let done = habits.filter { $0.completedDates.contains(dateKey) }.count
        return Double(done) / Double(habits.count)
    }

    // MARK: - Persistence
    private func save() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Habit].self, from: data)
        else { return }
        habits = decoded
    }
}

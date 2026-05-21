import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {

    // MARK: - Time of day
    @Published var timeOfDay: TimeOfDay = .current

    // MARK: - Daily content
    let thoughtOfDay: String  = DailyContent.todayThought
    let reminder: String      = DailyContent.todayReminder
    let joke: String          = DailyContent.todayJoke

    // MARK: - Scratch card state (persisted per day)
    @Published var hasScratched: Bool {
        didSet { saveScratchState() }
    }

    // MARK: - Animation phases
    @Published var greetingPhase: GreetingPhase = .centred
    @Published var currentCard: CardIndex = .scratch
    @Published var pillIsOpen: Bool = false

    enum GreetingPhase { case centred, header }
    enum CardIndex: Int, CaseIterable { case scratch, reminder, joke }

    // MARK: - Init
    init() {
        self.hasScratched = Self.loadScratchState()
        scheduleGreetingAnimation()
        refreshTimeOfDay()
    }

    // MARK: - Greeting animation
    private func scheduleGreetingAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            withAnimation(.spring(response: 0.75, dampingFraction: 0.75)) {
                self?.greetingPhase = .header
            }
        }
    }

    // MARK: - Refresh time every minute (handles midnight rollovers)
    private var timer: AnyCancellable?
    private func refreshTimeOfDay() {
        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                let new = TimeOfDay.current
                if new != self?.timeOfDay {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        self?.timeOfDay = new
                    }
                }
            }
    }

    // MARK: - Scratch persistence (resets daily)
    private static let scratchKey   = "scratchedDate"

    private static func loadScratchState() -> Bool {
        guard let saved = UserDefaults.standard.string(forKey: scratchKey) else { return false }
        return saved == todayKey()
    }

    private func saveScratchState() {
        if hasScratched {
            UserDefaults.standard.set(Self.todayKey(), forKey: Self.scratchKey)
        }
    }

    private static func todayKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}

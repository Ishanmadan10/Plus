import Foundation

struct DailyContent {

    // MARK: - Thoughts of the Day
    static let thoughts: [String] = [
        "You have survived 100% of your worst days so far 🌱",
        "Small steps still move you forward 🐾",
        "Rest is productive too 💤",
        "Your effort today is quietly building something great 🔨",
        "It's okay to not have it all figured out ✨",
        "You are allowed to be both a work in progress and enough right now 🌸",
        "One kind thought can change the whole day 💛",
        "The fact that you're trying counts for everything 🙌",
        "Breathe. You're doing better than you think 🌬️",
        "Today's a new chapter — even if yesterday's felt rough 📖"
    ]

    // MARK: - Reminders
    static let reminders: [String] = [
        "Hey, have you had water today? Cheers! 💧",
        "Take 3 deep breaths right now. Seriously, try it 🌬️",
        "Stand up, stretch a little — your back will thank you 🙆",
        "You haven't eaten in a while, haven't you? Grab something small 🍎",
        "Close a few tabs. Your brain needs white space too 💻",
        "Text someone who makes you smile today 📱",
        "Put your phone down for 10 minutes. The world can wait ⏸️",
        "One thing done well beats five things done anxiously ✅",
        "Your to-do list will survive if you rest for a bit 😌",
        "Go outside, even just for 5 minutes ☀️"
    ]

    // MARK: - Jokes (light, relatable, no dark humour)
    static let jokes: [String] = [
        "Me in traffic: 'I should leave earlier.' \nAlso me every morning: 🚗💨",
        "My manager asked for a word doc. \nI sent him the word 'doc' 📄",
        "My dog judged me for eating chips at 11am. \nNo notes from him though 🐶",
        "Monday is just Sunday's evil twin with a laptop 💻",
        "Why do cows wear bells? Because their horns don't work 🐄🔔",
        "Told my plant I believed in it. \nIt's still dead. Manifesting has limits 🪴",
        "My commute: 45 mins there. \nMy excuse for being 2 mins late: 'traffic' 🚌",
        "The office printer only jams when you're already late. \nEvery. Single. Time. 🖨️",
        "Me at 9am: today I'll be so productive! \nMe at 9:05am: one quick YouTube video... 📺",
        "Animals don't have Mondays. \nThis is why I respect animals 🦁"
    ]

    // MARK: - Deterministic daily pick (same content all day, changes at midnight)
    static func todayIndex(for array: [String]) -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return array[day % array.count]
    }

    static var todayThought: String  { todayIndex(for: thoughts) }
    static var todayReminder: String { todayIndex(for: reminders) }
    static var todayJoke: String     { todayIndex(for: jokes) }
}

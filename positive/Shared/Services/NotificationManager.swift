import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }

    // MARK: - Task Reminder
    func scheduleTaskReminder(task: String, at date: Date, section: String) {
        let content = UNMutableNotificationContent()
        content.title = taskTitle(task: task, section: section)
        content.body = taskBody(task: task)
        content.sound = .default

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let id = "task-\(task.hashValue)-\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Habit Reminder
    func scheduleHabitReminder(for habit: Habit) {
        cancelHabitReminder(for: habit)

        guard let time = parseTime(from: habit.title) ?? defaultHabitTime(for: habit.title) else { return }

        let content = UNMutableNotificationContent()
        content.title = habitTitle(for: habit.title)
        content.body = habitBody(for: habit.title)
        content.sound = .default

        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(
            identifier: habitID(for: habit),
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelHabitReminder(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [habitID(for: habit)]
        )
    }

    private func habitID(for habit: Habit) -> String {
        "habit-\(habit.id.uuidString)"
    }

    // MARK: - Time Parser
    // Reads "gym at 8pm", "sleep by 12", "wake up at 7:30am" etc.
    func parseTime(from text: String) -> Date? {
        let lower = text.lowercased()

        // patterns: "at 8pm", "at 8:30pm", "by 12", "by 11pm", "at 7am"
        let patterns = [
            #"(?:at|by)\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?"#
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(
                    in: lower,
                    range: NSRange(lower.startIndex..., in: lower)
                  )
            else { continue }

            var hour = 0
            var minute = 0
            var isPM: Bool? = nil

            if let r = Range(match.range(at: 1), in: lower) {
                hour = Int(lower[r]) ?? 0
            }
            if let r = Range(match.range(at: 2), in: lower), !lower[r].isEmpty {
                minute = Int(lower[r]) ?? 0
            }
            if let r = Range(match.range(at: 3), in: lower) {
                let ampm = String(lower[r])
                isPM = ampm == "pm"
            }

            // Apply AM/PM
            if let pm = isPM {
                if pm && hour < 12 { hour += 12 }
                if !pm && hour == 12 { hour = 0 }
            } else {
                // No AM/PM — assume PM for hours 1-11, midnight for 12
                if hour == 12 { hour = 0 }          // "by 12" = midnight
                else if hour < 7 { hour += 12 }     // "at 8" = 8 PM
            }

            var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            comps.hour = hour
            comps.minute = minute
            return Calendar.current.date(from: comps)
        }
        return nil
    }

    // Default times if no time found in name
    private func defaultHabitTime(for title: String) -> Date? {
        let lower = title.lowercased()
        var hour = 22  // default 10 PM for most habits

        if lower.contains("sleep") || lower.contains("bed") {
            hour = 23  // 11 PM nudge before midnight
        } else if lower.contains("morning") || lower.contains("wake") {
            hour = 7
        } else if lower.contains("gym") || lower.contains("workout") || lower.contains("exercise") {
            hour = 18  // 6 PM
        } else if lower.contains("read") || lower.contains("book") {
            hour = 21  // 9 PM
        } else if lower.contains("meditat") {
            hour = 8
        } else if lower.contains("laundry") || lower.contains("clothes") {
            hour = 10
        }

        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = 0
        return Calendar.current.date(from: comps)
    }

    // MARK: - Funny Habit Messages
    private func habitTitle(for title: String) -> String {
        let lower = title.lowercased()
        if lower.contains("gym") || lower.contains("workout") || lower.contains("exercise") {
            return "Your future self called 💪"
        } else if lower.contains("sleep") || lower.contains("bed") {
            return "Your pillow misses you 🌙"
        } else if lower.contains("read") || lower.contains("book") {
            return "The book won't read itself 📖"
        } else if lower.contains("laundry") || lower.contains("clothes") {
            return "The pile is judging you 🧺"
        } else if lower.contains("meditat") {
            return "Brain needs a minute 🧘"
        } else if lower.contains("water") || lower.contains("drink") {
            return "You're basically a plant 🌿"
        } else if lower.contains("phone") || lower.contains("screen") {
            return "The scroll can wait 📵"
        } else {
            return "Hey, a little nudge 👋"
        }
    }

    private func habitBody(for title: String) -> String {
        let lower = title.lowercased()
        if lower.contains("gym") || lower.contains("workout") || lower.contains("exercise") {
            return "You said you'd go. The weights are waiting. No pressure."
        } else if lower.contains("sleep") || lower.contains("bed") {
            return "Tomorrow needs you at full power. Close the phone. Just do it."
        } else if lower.contains("read") || lower.contains("book") {
            return "Even 10 pages counts. That's more than yesterday."
        } else if lower.contains("laundry") || lower.contains("clothes") {
            return "We both know it's been a while. Today's the day."
        } else if lower.contains("meditat") {
            return "Five minutes. That's it. You'll thank yourself."
        } else if lower.contains("water") || lower.contains("drink") {
            return "Drink some water. Like right now. Seriously."
        } else if lower.contains("phone") || lower.contains("screen") {
            return "Put it down. The internet will still be there tomorrow."
        } else {
            return "\(title). Still on the list. Still waiting for you."
        }
    }

    // MARK: - Funny Task Messages
    private func taskTitle(task: String, section: String) -> String {
        let lower = task.lowercased()
        if lower.contains("birthday") || lower.contains("bday") {
            return "Someone's getting older today 🎂"
        } else if lower.contains("call") || lower.contains("ring") {
            return "Don't ghost them 📞"
        } else if lower.contains("meeting") || lower.contains("meet") {
            return "Meeting time ⏰"
        } else if lower.contains("buy") || lower.contains("get") || lower.contains("pick") {
            return "Don't forget to grab this 🛍️"
        } else if lower.contains("email") || lower.contains("send") {
            return "Sitting in your drafts 📧"
        } else if lower.contains("pay") || lower.contains("bill") {
            return "Your wallet is calling 💸"
        } else {
            return "From your \(section) list 📌"
        }
    }

    private func taskBody(task: String) -> String {
        let lower = task.lowercased()
        if lower.contains("birthday") {
            return "You added this so you wouldn't forget. You're welcome."
        } else if lower.contains("call") {
            return "It's on your list. Make the call. Takes 5 minutes."
        } else if lower.contains("meeting") {
            return "You've got a meeting. Don't be that person who shows up late."
        } else if lower.contains("pay") || lower.contains("bill") {
            return "Past-you was responsible enough to write this down. Be like past-you."
        } else {
            return "\"\(task)\" — you wrote this because it mattered. Still does."
        }
    }
}

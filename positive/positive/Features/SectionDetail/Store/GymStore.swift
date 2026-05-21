import Foundation
import SwiftUI

final class GymStore: ObservableObject {

    @Published var days: [GymDay] = []

    @Published var logs: [GymLog] = []

    private let daysKey = "gymDays_v1"

    private let logsKey = "gymLogs_v1"

    init() {

        loadDays()
        loadLogs()

        if days.isEmpty {

            seedDefaults()
        }
    }

    // MARK: Days

    func addDay(name: String) {

        let d = GymDay(
            name: name,
            exercises: []
        )

        days.append(d)

        saveDays()
    }

    func deleteDay(at offsets: IndexSet) {

        days.remove(atOffsets: offsets)

        saveDays()
    }

    func addExercise(
        _ name: String,
        toDayWithID id: UUID
    ) {

        if let i = days.firstIndex(where: { $0.id == id }) {

            days[i].exercises.append(
                GymExercise(name: name)
            )

            saveDays()
        }
    }

    func deleteExercise(
        dayID: UUID,
        exerciseID: UUID
    ) {

        if let di = days.firstIndex(where: { $0.id == dayID }) {

            days[di].exercises.removeAll {
                $0.id == exerciseID
            }

            saveDays()
        }
    }

    func moveExercises(
        dayID: UUID,
        from: IndexSet,
        to: Int
    ) {

        if let di = days.firstIndex(where: { $0.id == dayID }) {

            days[di].exercises.move(
                fromOffsets: from,
                toOffset: to
            )

            saveDays()
        }
    }

    // MARK: Logs

    func saveLog(_ log: GymLog) {

        let cal = Calendar.current

        logs.removeAll {

            cal.isDate(
                $0.date,
                inSameDayAs: log.date
            ) && $0.dayName == log.dayName
        }

        logs.append(log)

        saveLogs()
    }

    func logs(for dayName: String) -> [GymLog] {

        logs
            .filter { $0.dayName == dayName }
            .sorted { $0.date > $1.date }
    }

    func logsOnDate(_ date: Date) -> [GymLog] {

        let cal = Calendar.current

        return logs.filter {

            cal.isDate(
                $0.date,
                inSameDayAs: date
            )
        }
    }

    // MARK: Persistence

    private func saveDays() {

        if let data = try? JSONEncoder().encode(days) {

            UserDefaults.standard.set(
                data,
                forKey: daysKey
            )
        }

        objectWillChange.send()
    }

    private func loadDays() {

        if let data = UserDefaults.standard.data(forKey: daysKey),
           let decoded = try? JSONDecoder().decode(
                [GymDay].self,
                from: data
           ) {

            days = decoded
        }
    }

    private func saveLogs() {

        if let data = try? JSONEncoder().encode(logs) {

            UserDefaults.standard.set(
                data,
                forKey: logsKey
            )
        }

        objectWillChange.send()
    }

    private func loadLogs() {

        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode(
                [GymLog].self,
                from: data
           ) {

            logs = decoded
        }
    }

    private func seedDefaults() {

        days = [

            GymDay(
                name: "Chest",
                exercises: [
                    GymExercise(name: "Bench press 3×10"),
                    GymExercise(name: "Incline press 3×10"),
                    GymExercise(name: "Cable flies 3×12"),
                    GymExercise(name: "Push-ups 3×15"),
                ]
            ),

            GymDay(
                name: "Back",
                exercises: [
                    GymExercise(name: "Deadlift 4×6"),
                    GymExercise(name: "Pull-ups 3×8"),
                    GymExercise(name: "Seated row 3×12"),
                    GymExercise(name: "Lat pulldown 3×10"),
                ]
            ),

            GymDay(
                name: "Legs",
                exercises: [
                    GymExercise(name: "Squat 4×8"),
                    GymExercise(name: "Leg press 3×12"),
                    GymExercise(name: "Romanian DL 3×10"),
                    GymExercise(name: "Calf raises 4×15"),
                ]
            ),

            GymDay(
                name: "Arms",
                exercises: [
                    GymExercise(name: "Barbell curl 3×10"),
                    GymExercise(name: "Hammer curl 3×12"),
                    GymExercise(name: "Tricep dip 3×12"),
                    GymExercise(name: "Skull crusher 3×10"),
                ]
            )
        ]

        saveDays()
    }
}

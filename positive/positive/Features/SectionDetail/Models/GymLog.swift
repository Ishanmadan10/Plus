import Foundation

struct GymLog: Identifiable, Codable {

    var id = UUID()

    var date: Date

    var dayName: String

    var completedExercises: [String]

    var notes: String

    var distanceKm: Double?

    var durationMin: Int?
}

import Foundation

struct GymDay: Identifiable, Codable, Equatable {

    var id = UUID()
    var name: String
    var exercises: [GymExercise]
}

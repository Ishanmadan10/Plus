import Foundation

struct PrayerCard: Identifiable {

    var id = UUID()
    var name: String
    var subtitle: String
    var frequency: String
    var time: String?
    var isCompleted: Bool = false
    var icon: String = "hands.sparkles"
}

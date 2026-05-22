import Foundation
import SwiftUI

struct JournalEntry: Identifiable {
    var id = UUID()
    var text: AttributedString
    var rawText: String
    var date: Date = Date()
}

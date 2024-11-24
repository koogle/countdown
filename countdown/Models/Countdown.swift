import Foundation

struct Countdown: Identifiable, Codable {
    let id: UUID
    var title: String
    var targetDate: Date
    
    init(id: UUID = UUID(), title: String, targetDate: Date) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
    }
} 
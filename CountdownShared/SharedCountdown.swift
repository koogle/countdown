import Foundation

public struct Countdown: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let targetDate: Date
    public let isStarred: Bool
    
    public init(id: UUID = UUID(), title: String, targetDate: Date, isStarred: Bool = false) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.isStarred = isStarred
    }
} 
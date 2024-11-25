import Foundation

public struct Countdown: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let targetDate: Date
    public let isStarred: Bool
    
    public var daysLeft: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return components.day ?? 0
    }
    
    public var isExpired: Bool {
        return targetDate < Date()
    }
    
    public init(id: UUID = UUID(), title: String, targetDate: Date, isStarred: Bool = false) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.isStarred = isStarred
    }
} 
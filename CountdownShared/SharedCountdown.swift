import Foundation

public struct Countdown: Identifiable, Codable, Hashable {
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
    
    public var timeRemainingText: String {
        let calendar = Calendar.current
        let now = Date()
        
        if isExpired {
            return "Expired"
        }
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: targetDate)
        
        if let days = components.day, days > 0 {
            return "\(days) \(days == 1 ? "day" : "days")"
        }
        
        if let hours = components.hour, hours > 0 {
            return "\(hours) \(hours == 1 ? "hour" : "hours")"
        }
        
        if let minutes = components.minute {
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes")"
        }
        
        return "Now"
    }
    
    public init(id: UUID = UUID(), title: String, targetDate: Date, isStarred: Bool = false) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.isStarred = isStarred
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Countdown, rhs: Countdown) -> Bool {
        return lhs.id == rhs.id
    }
}
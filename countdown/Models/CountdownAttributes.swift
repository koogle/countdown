import ActivityKit
import Foundation

struct CountdownAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: String
    }
    
    var title: String
    var targetDate: Date
} 
import Foundation

public enum SharedConfig {
    public static let appGroupIdentifier = "group.frick.jakob.countdown"
    public static let savedCountdownsKey = "savedCountdowns"
    
    public static var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
} 

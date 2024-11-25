import Foundation

public enum SharedConfig {
    public static let appGroupIdentifier = "group.frick.jakob.countdown"
    public static let savedCountdownsKey = "savedCountdowns"
    
    public static var sharedUserDefaults: UserDefaults? {
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        print("Debug - Creating shared UserDefaults with suite:", appGroupIdentifier)
        print("Debug - UserDefaults is nil:", defaults == nil)
        return defaults
    }
} 

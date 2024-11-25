import Foundation
import SwiftUI
import Combine
import WidgetKit

public class CountdownManager: ObservableObject {
    @Published public private(set) var countdowns: [Countdown] = []
    
    private let userDefaults: UserDefaults
    
    public init() {
        if let groupUserDefaults = UserDefaults(suiteName: SharedConfig.appGroupIdentifier) {
            self.userDefaults = groupUserDefaults
            print("Manager Manager Debug - Using group UserDefaults", SharedConfig.appGroupIdentifier)
        } else {
            self.userDefaults = .standard
            print("Manager Manager Debug - Fallback to standard UserDefaults")
        }
        
        loadCountdowns()
    }
    
    private func loadCountdowns() {
        if let data = userDefaults.data(forKey: SharedConfig.savedCountdownsKey) {
            if let decodedCountdowns = try? JSONDecoder().decode([Countdown].self, from: data) {
                countdowns = decodedCountdowns
                print("Manager Manager Debug - Loaded countdowns:", countdowns.map { "\($0.title) (starred: \($0.isStarred))" })
            } else {
                print("Manager Manager Debug - Failed to decode countdowns")
            }
        } else {
            print("Manager Manager Debug - No saved countdowns found")
        }
    }
    
    private func saveCountdowns() {
        if let encoded = try? JSONEncoder().encode(countdowns) {
            print("Manager Manager Debug - Saving to UserDefaults with suite:", SharedConfig.appGroupIdentifier)
            print("Manager Manager Debug - Using key:", SharedConfig.savedCountdownsKey)
            print("Manager Manager Debug - Data to save:", String(data: encoded, encoding: .utf8) ?? "Could not decode as string")
            
            userDefaults.set(encoded, forKey: SharedConfig.savedCountdownsKey)
            userDefaults.synchronize()
            
            // Verify the save
            if let savedData = userDefaults.data(forKey: SharedConfig.savedCountdownsKey) {
                print("Manager Manager Debug - Verified save - Data exists")
                print("Manager Manager Debug - Saved data:", String(data: savedData, encoding: .utf8) ?? "Could not decode as string")
            } else {
                print("Manager Manager Debug - Failed to verify save - No data found after saving")
            }
            
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            print("Manager Manager Debug - Failed to encode countdowns")
        }
    }
    
    public func unstarAllCountdowns() {
        countdowns = countdowns.map { countdown in
            Countdown(
                id: countdown.id,
                title: countdown.title,
                targetDate: countdown.targetDate,
                isStarred: false
            )
        }
        saveCountdowns()
    }
    
    public var starredCountdown: Countdown? {
        countdowns.first { $0.isStarred }
    }
    
    public func updateCountdown(_ oldCountdown: Countdown, with newCountdown: Countdown) {
        if let index = countdowns.firstIndex(where: { $0.id == oldCountdown.id }) {
            if newCountdown.isStarred {
                unstarAllCountdowns()
            }
            countdowns[index] = newCountdown
            saveCountdowns()
        }
    }
    
    public func addCountdown(_ countdown: Countdown) {
        if countdown.isStarred {
            unstarAllCountdowns()
        }
        countdowns.append(countdown)
        saveCountdowns()
    }
    
    public func deleteCountdown(_ countdown: Countdown) {
        countdowns.removeAll { $0.id == countdown.id }
        saveCountdowns()
    }
} 

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
        } else {
            self.userDefaults = .standard
        }
        
        loadCountdowns()
    }
    
    private func loadCountdowns() {
        if let data = userDefaults.data(forKey: SharedConfig.savedCountdownsKey),
           let decodedCountdowns = try? JSONDecoder().decode([Countdown].self, from: data) {
            countdowns = decodedCountdowns
        }
    }
    
    private func saveCountdowns() {
        if let encoded = try? JSONEncoder().encode(countdowns) {
            userDefaults.set(encoded, forKey: SharedConfig.savedCountdownsKey)
            userDefaults.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
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
        var newCountdown = countdown
        // If this is the first countdown, star it automatically
        if countdowns.isEmpty {
            newCountdown = Countdown(
                id: countdown.id,
                title: countdown.title,
                targetDate: countdown.targetDate,
                isStarred: true
            )
        } else if countdown.isStarred {
            unstarAllCountdowns()
        }
        countdowns.append(newCountdown)
        saveCountdowns()
    }
    
    public func deleteCountdown(_ countdown: Countdown) {
        let wasStarred = countdown.isStarred
        countdowns.removeAll { $0.id == countdown.id }
        
        // If we deleted a starred countdown, star the next available one
        if wasStarred && !countdowns.isEmpty {
            // Try to star the first non-expired countdown, otherwise star the first one
            if let nextCountdown = countdowns.first(where: { !$0.isExpired }) ?? countdowns.first {
                let starredCountdown = Countdown(
                    id: nextCountdown.id,
                    title: nextCountdown.title,
                    targetDate: nextCountdown.targetDate,
                    isStarred: true
                )
                updateCountdown(nextCountdown, with: starredCountdown)
            }
        } else {
            saveCountdowns()
        }
    }
} 

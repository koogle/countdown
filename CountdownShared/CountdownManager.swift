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

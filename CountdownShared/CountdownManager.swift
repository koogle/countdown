import Foundation
import SwiftUI

public class CountdownManager: ObservableObject {
    @Published public private(set) var countdowns: [Countdown] = []
    
    private let userDefaults: UserDefaults
    private let coundownsKey = "countdowns"
    
    public init() {
        if let groupUserDefaults = UserDefaults(suiteName: "group.frick.jakob.countdown") {
            self.userDefaults = groupUserDefaults
        } else {
            self.userDefaults = .standard
        }
        
        loadCountdowns()
    }
    
    private func loadCountdowns() {
        if let data = userDefaults.data(forKey: coundownsKey),
           let decodedCountdowns = try? JSONDecoder().decode([Countdown].self, from: data) {
            countdowns = decodedCountdowns
        }
    }
    
    private func saveCountdowns() {
        if let encoded = try? JSONEncoder().encode(countdowns) {
            userDefaults.set(encoded, forKey: coundownsKey)
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
import Foundation
import Combine

class CountdownViewModel: ObservableObject {
    @Published var countdowns: [Countdown] = [] {
        didSet {
            saveCountdowns()
        }
    }
    
    private let saveKey = "SavedCountdowns"
    private var timer: AnyCancellable?
    
    init() {
        loadCountdowns()
        setupLiveActivityUpdates()
    }
    
    func addCountdown(_ countdown: Countdown) {
        countdowns.append(countdown)
        LiveActivityService.shared.startLiveActivity(for: countdown)
    }
    
    func removeCountdown(at indexSet: IndexSet) {
        countdowns.remove(atOffsets: indexSet)
    }
    
    private func saveCountdowns() {
        if let encoded = try? JSONEncoder().encode(countdowns) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadCountdowns() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Countdown].self, from: data) {
                countdowns = decoded
            }
        }
    }
    
    private func setupLiveActivityUpdates() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                LiveActivityService.shared.updateLiveActivities()
            }
    }
    
    deinit {
        timer?.cancel()
    }
} 
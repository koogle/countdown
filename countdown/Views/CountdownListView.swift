import SwiftUI
import CountdownShared

struct CountdownListView: View {
    @StateObject private var countdownManager = CountdownManager()
    @State private var showingAddCountdown = false
    @State private var selectedCountdown: Countdown?
    
    var sortedUpcomingCountdowns: [Countdown] {
        countdownManager.countdowns
            .filter { !$0.isExpired }
            .sorted { first, second in
                if first.isStarred != second.isStarred {
                    return first.isStarred
                }
                return first.targetDate < second.targetDate
            }
    }
    
    var sortedExpiredCountdowns: [Countdown] {
        countdownManager.countdowns
            .filter { $0.isExpired }
            .sorted { $0.targetDate > $1.targetDate }
    }
    
    @ViewBuilder
    func countdownRow(_ countdown: Countdown) -> some View {
        NavigationLink(value: countdown) {
            CountdownRow(countdown: countdown) {
                toggleStar(for: countdown)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                countdownManager.deleteCountdown(countdown)
            } label: {
                Text("Delete")
            }
        }
    }
    
    private func toggleStar(for countdown: Countdown) {
        let newCountdown = Countdown(
            id: countdown.id,
            title: countdown.title,
            targetDate: countdown.targetDate,
            isStarred: !countdown.isStarred
        )
        countdownManager.updateCountdown(countdown, with: newCountdown)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if countdownManager.countdowns.isEmpty {
                    EmptyStateView(showingAddCountdown: $showingAddCountdown)
                } else {
                    List {
                        Section("Upcoming Countdowns") {
                            ForEach(sortedUpcomingCountdowns) { countdown in
                                countdownRow(countdown)
                            }
                        }
                        
                        if !sortedExpiredCountdowns.isEmpty {
                            Section("Expired") {
                                ForEach(sortedExpiredCountdowns) { countdown in
                                    countdownRow(countdown)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Countdowns")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCountdown = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCountdown) {
                AddCountdownView(countdownManager: countdownManager)
            }
            .navigationDestination(for: Countdown.self) { countdown in
                CountdownDetailView(countdown: countdown)
            }
        }
        .navigationViewStyle(.automatic)
        .onAppear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                selectedCountdown = sortedUpcomingCountdowns.first
            }
        }
    }
}

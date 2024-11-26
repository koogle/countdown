import SwiftUI
import CountdownShared

struct CountdownListView: View {
    @StateObject private var countdownManager = CountdownManager()
    @State private var showingAddCountdown = false
    @State private var countdownToEdit: Countdown?
    @State private var selectedCountdown: Countdown?
    
    var sortedUpcomingCountdowns: [Countdown] {
        countdownManager.countdowns
            .filter { !$0.isExpired }
            .sorted { first, second in
                if first.isStarred != second.isStarred {
                    return first.isStarred // Starred items come first
                }
                return first.targetDate < second.targetDate // Then sort by date
            }
    }
    
    var sortedExpiredCountdowns: [Countdown] {
        countdownManager.countdowns
            .filter { $0.isExpired }
            .sorted { $0.targetDate > $1.targetDate } // Most recently expired first
    }
    
    var body: some View {
        NavigationView {
            Group {
                if countdownManager.countdowns.isEmpty {
                    EmptyStateView(showingAddCountdown: $showingAddCountdown)
                } else {
                    List(selection: $selectedCountdown) {
                        Section("Upcoming Countdowns") {
                            ForEach(sortedUpcomingCountdowns) { countdown in
                                NavigationLink(
                                    destination: CountdownDetailView(countdown: countdown),
                                    tag: countdown,
                                    selection: $selectedCountdown
                                ) {
                                    CountdownRow(countdown: countdown) {
                                        let newCountdown = Countdown(
                                            id: countdown.id,
                                            title: countdown.title,
                                            targetDate: countdown.targetDate,
                                            isStarred: !countdown.isStarred
                                        )
                                        countdownManager.updateCountdown(countdown, with: newCountdown)
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
                        }
                        
                        if !sortedExpiredCountdowns.isEmpty {
                            Section("Expired") {
                                ForEach(sortedExpiredCountdowns) { countdown in
                                    NavigationLink(
                                        destination: CountdownDetailView(countdown: countdown),
                                        tag: countdown,
                                        selection: $selectedCountdown
                                    ) {
                                        CountdownRow(countdown: countdown) {
                                            let newCountdown = Countdown(
                                                id: countdown.id,
                                                title: countdown.title,
                                                targetDate: countdown.targetDate,
                                                isStarred: !countdown.isStarred
                                            )
                                            countdownManager.updateCountdown(countdown, with: newCountdown)
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
            
            // Default view for iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                Text("Select a countdown")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationViewStyle(.automatic)
        .onAppear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                // Select the first countdown by default on iPad
                selectedCountdown = sortedUpcomingCountdowns.first
            }
        }
    }
}

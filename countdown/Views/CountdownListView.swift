import SwiftUI
import CountdownShared

struct CountdownListView: View {
    @StateObject private var countdownManager = CountdownManager()
    @State private var showingAddCountdown = false
    @State private var editingCountdown: Countdown?  // New state to hold the countdown being edited
    
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
        CountdownRow(countdown: countdown) {
            toggleStar(for: countdown)
        }
        .onTapGesture {
            debugPrint("🔍 Tapped countdown: \(countdown.title)")
            editingCountdown = countdown  // Store the countdown to edit
            debugPrint("🔍 Stored editing countdown: \(editingCountdown?.title ?? "<none>")")
            showingAddCountdown = true
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
        NavigationView {
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
            .safeAreaInset(edge: .top, content: {
                HStack {
                    Spacer()
                    Button(action: { 
                        editingCountdown = nil  // Clear editing countdown for new countdown
                        showingAddCountdown = true 
                    }) {
                        Image(systemName: "plus")
                    }
                    .padding(.trailing)
                }
                .background(Color.clear)
            })
            .sheet(isPresented: $showingAddCountdown) {
                if let countdown = editingCountdown {  // Use editingCountdown instead
                    // debugPrint("🔍 Opening edit view for: \(countdown.title)")
                    AddCountdownView(countdownManager: countdownManager, countdown: countdown)
                } else {
                    // debugPrint("🔍 Opening add view (no countdown selected)")
                    AddCountdownView(countdownManager: countdownManager)
                }
            }
        }
        .navigationViewStyle(.automatic)
    }
}

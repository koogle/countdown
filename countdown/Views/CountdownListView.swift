import SwiftUI
import CountdownShared

struct CountdownListView: View {
    @StateObject private var countdownManager = CountdownManager()
    @State private var showingAddCountdown = false
    @State private var countdownToEdit: Countdown?
    
    var body: some View {
        NavigationView {
            Group {
                if countdownManager.countdowns.isEmpty {
                    EmptyStateView(showingAddCountdown: $showingAddCountdown)
                } else {
                    List {
                        Section("Upcoming Countdowns") {
                            ForEach(countdownManager.countdowns.filter { !$0.isExpired }) { countdown in
                                CountdownRow(countdown: countdown)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            countdownManager.deleteCountdown(countdown)
                                        } label: {
                                            Text("Delete")
                                        }
                                        
                                        Button {
                                            countdownToEdit = countdown
                                        } label: {
                                            Text("Edit")
                                        }
                                        .tint(.blue)
                                    }
                            }
                        }
                        
                        if !countdownManager.countdowns.filter({ $0.isExpired }).isEmpty {
                            Section("Expired") {
                                ForEach(countdownManager.countdowns.filter { $0.isExpired }) { countdown in
                                    CountdownRow(countdown: countdown)
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                countdownManager.deleteCountdown(countdown)
                                            } label: {
                                                Text("Delete")
                                            }
                                            
                                            Button {
                                                countdownToEdit = countdown
                                            } label: {
                                                Text("Edit")
                                            }
                                            .tint(.blue)
                                        }
                                }
                            }
                        }
                    }
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
            .sheet(item: $countdownToEdit) { countdown in
                AddCountdownView(countdownManager: countdownManager, countdown: countdown)
            }
        }
    }
} 
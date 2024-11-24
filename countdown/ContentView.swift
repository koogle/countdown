//
//  ContentView.swift
//  countdown
//
//  Created by Jakob Frick on 24/11/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CountdownViewModel()
    @State private var showingAddCountdown = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.countdowns) { countdown in
                    CountdownRow(countdown: countdown)
                }
                .onDelete(perform: viewModel.removeCountdown)
            }
            .navigationTitle("Countdowns")
            .toolbar {
                Button(action: {
                    showingAddCountdown = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddCountdown) {
                AddCountdownView(viewModel: viewModel)
            }
        }
    }
}

struct CountdownRow: View {
    let countdown: Countdown
    @State private var timeRemaining: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(countdown.title)
                .font(.headline)
            Text(timeRemaining)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], 
                                               from: Date(), 
                                               to: countdown.targetDate)
        
        if let days = components.day, let hours = components.hour, 
           let minutes = components.minute, let seconds = components.second {
            if days > 0 {
                timeRemaining = "\(days)d \(hours)h \(minutes)m"
            } else if hours > 0 {
                timeRemaining = "\(hours)h \(minutes)m \(seconds)s"
            } else {
                timeRemaining = "\(minutes)m \(seconds)s"
            }
        }
    }
}

#Preview {
    ContentView()
}

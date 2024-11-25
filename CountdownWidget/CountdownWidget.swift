//
//  CountdownWidget.swift
//  CountdownWidget
//
//  Created by Jakob Frick on 24/11/2024.
//

import WidgetKit
import SwiftUI
import Intents
import CountdownShared

struct CountdownWidget: Widget {
    private let kind = "CountdownWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: CountdownTimelineProvider()) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Countdown Days")
        .description("Shows days remaining for your selected countdown.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct CountdownEntry: TimelineEntry {
    let date: Date
    let countdown: CountdownShared.Countdown
    let configuration: ConfigurationIntent
}

struct CountdownTimelineProvider: IntentTimelineProvider {
    typealias Intent = ConfigurationIntent
    typealias Entry = CountdownEntry
    
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(
            date: Date(),
            countdown: CountdownShared.Countdown(
                title: "Sample",
                targetDate: Date().addingTimeInterval(7*24*60*60)
            ),
            configuration: ConfigurationIntent()
        )
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let userDefaults = CountdownShared.SharedConfig.sharedUserDefaults
        print("Widget Debug - UserDefaults:", userDefaults?.dictionaryRepresentation().keys ?? "nil")
        
        var countdown = CountdownShared.Countdown(
            title: "Select countdown",
            targetDate: Date().addingTimeInterval(24*60*60)
        )
        
        if let data = userDefaults?.data(forKey: CountdownShared.SharedConfig.savedCountdownsKey) {
            print("Widget Debug - Found data for key:", CountdownShared.SharedConfig.savedCountdownsKey)
            
            if let countdowns = try? JSONDecoder().decode([Countdown].self, from: data) {
                print("Widget Debug - Decoded countdowns:", countdowns.map { "\($0.title) (starred: \($0.isStarred))" })
                
                if let starredCountdown = countdowns.first(where: { $0.isStarred }) {
                    print("Widget Debug - Found starred countdown:", starredCountdown.title)
                    countdown = starredCountdown
                } else if let selectedId = configuration.countdownId,
                          let selectedCountdown = countdowns.first(where: { $0.id.uuidString == selectedId }) {
                    print("Widget Debug - Found selected countdown:", selectedCountdown.title)
                    countdown = selectedCountdown
                } else if let nextCountdown = countdowns
                    .filter({ !$0.isExpired })
                    .sorted(by: { $0.targetDate < $1.targetDate })
                    .first {
                    print("Widget Debug - Using first upcoming countdown:", nextCountdown.title)
                    countdown = nextCountdown
                }
            } else {
                print("Widget Debug - Failed to decode countdowns")
            }
        } else {
            print("Widget Debug - No data found for key:", CountdownShared.SharedConfig.savedCountdownsKey)
        }
        
        print("Widget Debug - Final countdown used:", countdown.title)
        
        let entry = CountdownEntry(
            date: Date(),
            countdown: countdown,
            configuration: configuration
        )
        
        let calendar = Calendar.current
        let nextUpdate = calendar.startOfDay(for: Date()).addingTimeInterval(24 * 60 * 60)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct CountdownWidgetView: View {
    let entry: CountdownEntry
    
    var body: some View {
        VStack {
            if entry.countdown.isExpired {
                Text("\(abs(entry.countdown.daysLeft))")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.gray)
                    .strikethrough()
            } else {
                Text("\(entry.countdown.daysLeft)")
                    .font(.system(size: 38, weight: .bold))
            }
            
            Text(entry.countdown.title)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.white.opacity(0.8), for: .widget)
    }
}

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

// Add this function at the file level:
func widgetBackground<Content: View>(_ content: Content) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
        return content
            .containerBackground(.white.opacity(0.8), for: .widget)
    } else {
        return content
            .background(.white.opacity(0.8))
    }
}

struct CountdownWidget: Widget {
    private let kind = "CountdownWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: CountdownTimelineProvider()) { entry in
            switch entry.family {
            case .accessoryRectangular:
                CountdownWidgetRowView(entry: entry)
            case .accessoryCircular:
                CountdownWidgetCircularView(entry: entry)
            case .systemMedium:
                CountdownWidgetMediumView(entry: entry)
            default:
                CountdownWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("Count down the days")
        .description("Shows days remaining for your stared countdown.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

struct CountdownEntry: TimelineEntry {
    let date: Date
    let countdown: CountdownShared.Countdown
    let configuration: ConfigurationIntent
    let family: WidgetFamily
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
            configuration: ConfigurationIntent(),
            family: .systemSmall
        )
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let userDefaults: UserDefaults
        if let groupUserDefaults = UserDefaults(suiteName: SharedConfig.appGroupIdentifier) {
            userDefaults = groupUserDefaults
        } else {
            userDefaults = .standard
        }
        
        var countdown = CountdownShared.Countdown(
            title: "Select countdown",
            targetDate: Date().addingTimeInterval(24*60*60)
        )
        
        if let data = userDefaults.data(forKey: SharedConfig.savedCountdownsKey),
           let countdowns = try? JSONDecoder().decode([Countdown].self, from: data) {
            if let starredCountdown = countdowns.first(where: { $0.isStarred }) {
                countdown = starredCountdown
            } else if let selectedId = configuration.countdownId,
                      let selectedCountdown = countdowns.first(where: { $0.id.uuidString == selectedId }) {
                countdown = selectedCountdown
            } else if let nextCountdown = countdowns
                .filter({ !$0.isExpired })
                .sorted(by: { $0.targetDate < $1.targetDate })
                .first {
                countdown = nextCountdown
            }
        }
        
        let currentDate = Date()
        var entries: [CountdownEntry] = []
        
        // Create entries for every minute in the next hour
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = CountdownEntry(
                date: entryDate,
                countdown: countdown,
                configuration: configuration,
                family: context.family
            )
            entries.append(entry)
        }
        
        // Schedule next update in an hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

@available(iOSApplicationExtension 16.0, *)
struct CountdownWidgetRowView: View {
    let entry: CountdownEntry
    
    var body: some View {
        if entry.countdown.title == "Select countdown" {
            widgetBackground(
                Text("Star a countdown")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            )
        } else {
            widgetBackground(
                VStack(alignment: .leading) {
                    Text(entry.countdown.title)
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                    if entry.countdown.isExpired {
                        Text("Completed")
                            .font(.system(.body))
                            .foregroundColor(.gray)
                    } else {
                        Text("\(entry.countdown.daysLeft) days")
                            .font(.system(.body))
                    }
                }
            )
        }
    }
}

struct CountdownWidgetView: View {
    let entry: CountdownEntry
    
    var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: entry.countdown.targetDate)
        return (
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0,
            seconds: components.second ?? 0
        )
    }
    
    var body: some View {
        if entry.countdown.title == "Select countdown" {
            widgetBackground(
                VStack(alignment: .leading, spacing: 4) {
                    Text("Please")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Text("star a")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Text("countdown")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
            )
        } else {
            widgetBackground(
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.countdown.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    if entry.countdown.isExpired {
                        Text("Done")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.gray)
                    } else {
                        Text("\(timeComponents.days)")
                            .font(.system(size: 38, weight: .bold))
                        
                        Text("days")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
            )
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
struct CountdownWidgetCircularView: View {
    let entry: CountdownEntry
    
    var body: some View {
        if entry.countdown.title == "Select countdown" {
            widgetBackground(
                Text("Star")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            )
        } else {
            widgetBackground(
                VStack(spacing: 2) {
                    Text(entry.countdown.title)
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    if entry.countdown.isExpired {
                        Text("Done")
                            .font(.system(size: 16, weight: .bold))
                    } else {
                        Text("\(entry.countdown.daysLeft)")
                            .font(.system(size: 20, weight: .bold))
                        Text("days")
                            .font(.system(size: 12))
                    }
                }
            )
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
struct CountdownWidgetMediumView: View {
    let entry: CountdownEntry
    
    var timeComponents: (days: Int, hours: Int, minutes: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: Date(), to: entry.countdown.targetDate)
        return (
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0
        )
    }
    
    var body: some View {
        if entry.countdown.title == "Select countdown" {
            widgetBackground(
                VStack {
                    Text("Star a countdown")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            )
        } else {
            widgetBackground(
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.countdown.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    if entry.countdown.isExpired {
                        Text("Completed")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.gray)
                    } else {
                        Text("\(timeComponents.days) days")
                            .font(.system(size: 42, weight: .semibold))
                            .padding(.vertical, 2)
                        
                        HStack(spacing: 4) {
                            Text("\(timeComponents.hours) hours")
                            Text("\(timeComponents.minutes) minutes")
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
            )
        }
    }
}

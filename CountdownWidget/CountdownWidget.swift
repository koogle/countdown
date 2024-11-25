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
            if #available(iOSApplicationExtension 16.0, *) {
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
            } else {
                CountdownWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("Countdown Days")
        .description("Shows days remaining for your selected countdown.")
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
        
        let entry = CountdownEntry(
            date: Date(),
            countdown: countdown,
            configuration: configuration,
            family: context.family
        )
        
        let nextUpdate = Date().addingTimeInterval(5)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

@available(iOSApplicationExtension 16.0, *)
struct CountdownWidgetRowView: View {
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
    
    var timeText: String {
        if entry.countdown.isExpired {
            return "\(abs(timeComponents.days))d ago"
        } else {
            if timeComponents.days > 0 {
                return String(format: "%dd %02dh %02dm %02ds", 
                            timeComponents.days,
                            timeComponents.hours,
                            timeComponents.minutes,
                            timeComponents.seconds)
            } else if timeComponents.hours > 0 {
                return String(format: "%dh %02dm %02ds",
                            timeComponents.hours,
                            timeComponents.minutes,
                            timeComponents.seconds)
            } else {
                return String(format: "%dm %02ds",
                            timeComponents.minutes,
                            timeComponents.seconds)
            }
        }
    }
    
    var body: some View {
        if entry.countdown.title == "Select countdown" {
            Text("Star a countdown")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        } else {
            HStack {
                Text(entry.countdown.title)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(1)
                Spacer()
                Text(timeText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gray)
            }
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
            VStack(spacing: 4) {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(.white.opacity(0.8), for: .widget)
        } else {
            VStack(spacing: 4) {
                if entry.countdown.isExpired {
                    Text("\(abs(entry.countdown.daysLeft))")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.gray)
                        .strikethrough()
                    Text("days")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                } else {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(timeComponents.days)")
                            .font(.system(size: 38, weight: .bold))
                        Text("days")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
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
}

@available(iOSApplicationExtension 16.0, *)
struct CountdownWidgetCircularView: View {
    let entry: CountdownEntry
    
    var body: some View {
        if entry.countdown.title == "Select countdown" {
            Text("Star")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        } else {
            Gauge(value: 1) {
                VStack(spacing: 2) {
                    Text("\(abs(entry.countdown.daysLeft))")
                        .font(.system(size: 20, weight: .bold))
                        .minimumScaleFactor(0.5)
                    Text(entry.countdown.title)
                        .font(.system(size: 12))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            }
            .gaugeStyle(.accessoryCircular)
        }
    }
}

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
            HStack {
                Text("Star a countdown")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding()
            .containerBackground(.white.opacity(0.8), for: .widget)
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.countdown.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if entry.countdown.isExpired {
                        Text("\(abs(timeComponents.days)) days ago")
                            .font(.title)
                            .foregroundColor(.gray)
                            .strikethrough()
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(timeComponents.days) days")
                                .font(.title)
                            HStack(spacing: 4) {
                                Text("\(timeComponents.hours) hours")
                                Text("\(timeComponents.minutes) min")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .containerBackground(.white.opacity(0.8), for: .widget)
        }
    }
}

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.frick.jakob.countdown")!
    
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: Date(), countdown: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> ()) {
        let entry = CountdownEntry(date: Date(), countdown: getStarredCountdown())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        let entry = CountdownEntry(date: currentDate, countdown: getStarredCountdown())
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        
        completion(timeline)
    }
    
    private func getStarredCountdown() -> Countdown? {
        guard let data = userDefaults.data(forKey: "countdowns"),
              let countdowns = try? JSONDecoder().decode([Countdown].self, from: data) else {
            return nil
        }
        return countdowns.first { $0.isStarred }
    }
}

struct CountdownEntry: TimelineEntry {
    let date: Date
    let countdown: Countdown?
}

struct CountdownWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if let countdown = entry.countdown {
            VStack(alignment: .leading) {
                Text(countdown.title)
                    .font(.headline)
                
                Text(countdown.targetDate, style: .relative)
                    .font(.subheadline)
            }
            .padding()
        } else {
            Text("No starred countdown")
                .padding()
        }
    }
}

@main
struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CountdownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countdown")
        .description("Shows your starred countdown.")
        .supportedFamilies([.systemSmall])
    }
} 
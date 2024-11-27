//
//  CountdownWidgetLiveActivity.swift
//  CountdownWidget
//
//  Created by Jakob Frick on 24/11/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI
import CountdownShared

struct CountdownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var countdown: Countdown
    }

    var name: String
}

struct CountdownWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountdownWidgetAttributes.self) { context in
            if #available(iOS 17.0, *) {
                LiveActivityView(context: context)
                    .containerBackground(.white.opacity(0.8), for: .widget)
            } else {
                LiveActivityView(context: context)
                    .background(.white.opacity(0.8))
            }
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.countdown.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.countdown.daysLeft)d")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("Target: ")
                            .foregroundStyle(.secondary)
                        Text(context.state.countdown.targetDate, style: .date)
                    }
                    .font(.subheadline)
                }
            } compactLeading: {
                Text(context.state.countdown.title)
                    .font(.caption)
                    .lineLimit(1)
            } compactTrailing: {
                Text("\(context.state.countdown.daysLeft)d")
                    .font(.caption)
            } minimal: {
                Text("\(context.state.countdown.daysLeft)")
            }
        }
    }
}

struct LiveActivityView: View {
    let context: ActivityViewContext<CountdownWidgetAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            Text(context.state.countdown.title)
                .font(.headline)
            
            Text("\(context.state.countdown.daysLeft)")
                .font(.system(size: 36, weight: .bold))
            
            Text("days remaining")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(context.state.countdown.targetDate, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview("Live Activity", as: .dynamicIsland(.expanded), using: CountdownWidgetAttributes(name: "Preview")) {
    CountdownWidgetLiveActivity()
} contentStates: {
    CountdownWidgetAttributes.ContentState(
        countdown: Countdown(
            title: "New Year",
            targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        )
    )
}

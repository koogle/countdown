import WidgetKit
import SwiftUI
import ActivityKit

struct CountdownLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountdownAttributes.self) { context in
            HStack {
                Text(context.attributes.title)
                    .font(.headline)
                Spacer()
                Text(context.state.timeRemaining)
                    .font(.subheadline)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.title)
                        .font(.headline)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.timeRemaining)
                        .font(.subheadline)
                }
            } compactLeading: {
                Text(context.attributes.title)
            } compactTrailing: {
                Text(context.state.timeRemaining)
            } minimal: {
                Text(context.state.timeRemaining)
            }
        }
    }
} 
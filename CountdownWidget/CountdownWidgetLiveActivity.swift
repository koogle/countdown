//
//  CountdownWidgetLiveActivity.swift
//  CountdownWidget
//
//  Created by Jakob Frick on 24/11/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CountdownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CountdownWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountdownWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CountdownWidgetAttributes {
    fileprivate static var preview: CountdownWidgetAttributes {
        CountdownWidgetAttributes(name: "World")
    }
}

extension CountdownWidgetAttributes.ContentState {
    fileprivate static var smiley: CountdownWidgetAttributes.ContentState {
        CountdownWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CountdownWidgetAttributes.ContentState {
         CountdownWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CountdownWidgetAttributes.preview) {
   CountdownWidgetLiveActivity()
} contentStates: {
    CountdownWidgetAttributes.ContentState.smiley
    CountdownWidgetAttributes.ContentState.starEyes
}

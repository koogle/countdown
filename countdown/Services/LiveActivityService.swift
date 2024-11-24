import ActivityKit
import Foundation

class LiveActivityService {
    static let shared = LiveActivityService()
    
    private init() {}
    
    func startLiveActivity(for countdown: Countdown) {
        let attributes = CountdownAttributes(
            title: countdown.title,
            targetDate: countdown.targetDate
        )
        
        let contentState = CountdownAttributes.ContentState(
            timeRemaining: formatTimeRemaining(to: countdown.targetDate)
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            print("Started live activity: \(activity.id)")
        } catch {
            print("Error starting live activity: \(error.localizedDescription)")
        }
    }
    
    func updateLiveActivities() {
        Task {
            for activity in Activity<CountdownAttributes>.activities {
                let contentState = CountdownAttributes.ContentState(
                    timeRemaining: formatTimeRemaining(to: activity.attributes.targetDate)
                )
                await activity.update(using: contentState)
            }
        }
    }
    
    private func formatTimeRemaining(to date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], 
                                               from: Date(), 
                                               to: date)
        
        if let days = components.day, let hours = components.hour, 
           let minutes = components.minute, let seconds = components.second {
            if days > 0 {
                return "\(days)d \(hours)h \(minutes)m"
            } else if hours > 0 {
                return "\(hours)h \(minutes)m \(seconds)s"
            } else {
                return "\(minutes)m \(seconds)s"
            }
        }
        return ""
    }
} 
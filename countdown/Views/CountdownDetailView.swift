import SwiftUI
import CountdownShared

struct CountdownDetailView: View {
    let countdown: Countdown
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(countdown.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                VStack(spacing: 8) {
                    if countdown.isExpired {
                        Text("Expired")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(countdown.targetDate.formatted(date: .long, time: .shortened))
                            .font(.title2)
                            .foregroundColor(.secondary)
                    } else {
                        Text(countdown.timeRemainingText)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("until")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(countdown.targetDate.formatted(date: .long, time: .shortened))
                            .font(.title2)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(15)
                
                if countdown.isStarred {
                    Label("Featured Countdown", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    CountdownDetailView(countdown: Countdown(
        id: UUID(),
        title: "Sample Countdown",
        targetDate: Date().addingTimeInterval(86400),
        isStarred: true
    ))
}

import SwiftUI
import CountdownShared

struct CountdownRow: View {
    let countdown: Countdown
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if countdown.isExpired {
                Text(countdown.title)
                    .font(.headline)
                    .strikethrough()
                Text("Expired \(abs(countdown.daysLeft)) days ago")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text(countdown.title)
                    .font(.headline)
                Text("\(countdown.daysLeft) days left")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
} 
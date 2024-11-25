import SwiftUI
import CountdownShared

struct CountdownRow: View {
    let countdown: Countdown
    let onStar: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(countdown.title)
                    .font(.headline)
                Text(countdown.isExpired ? "\(abs(countdown.daysLeft)) days ago" : "\(countdown.daysLeft) days left")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onStar) {
                Image(systemName: countdown.isStarred ? "star.fill" : "star")
                    .foregroundColor(countdown.isStarred ? .yellow : .gray)
            }
        }
        .contentShape(Rectangle())
    }
} 
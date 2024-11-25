import SwiftUI
import CountdownShared

struct CountdownRow: View {
    let countdown: Countdown
    let onStar: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(countdown.title)
                    .font(.headline)
                Text(countdown.isExpired ? "\(abs(countdown.daysLeft)) days ago" : "\(countdown.daysLeft) days left")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            Button(action: onStar) {
                Image(systemName: countdown.isStarred ? "star.fill" : "star")
                    .foregroundColor(countdown.isStarred ? .yellow : .gray)
                    .font(.system(size: 22))
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)
        }
        .contentShape(Rectangle())
    }
} 
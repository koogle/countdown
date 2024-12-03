import SwiftUI

struct EmptyStateView: View {
    @Binding var showingAddCountdown: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Countdowns Yet")
                .font(.title2)
                .foregroundColor(.gray)
            
            Button(action: { showingAddCountdown = true }) {
                Text("New Countdown")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
} 
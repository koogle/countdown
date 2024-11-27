import SwiftUI
import CountdownShared

struct AddCountdownView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var countdownManager: CountdownManager
    @Binding var editingCountdown: Countdown?
    
    @State private var title: String
    @State private var targetDate: Date
    @State private var includeTime: Bool
    
    init(countdownManager: CountdownManager, editingCountdown: Binding<Countdown?>) {
        self.countdownManager = countdownManager
        self._editingCountdown = editingCountdown
        
        // Initialize state variables
        _title = State(initialValue: editingCountdown.wrappedValue?.title ?? "")
        _targetDate = State(initialValue: editingCountdown.wrappedValue?.targetDate ?? Date().addingTimeInterval(7*24*60*60))
        _includeTime = State(initialValue: false)
    }
    
    var body: some View {
        NavigationView {
            List {
                TextField("Title", text: $title)
                    .font(.headline)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                DatePicker(
                    "Date",
                    selection: $targetDate,
                    displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date]
                )
                .foregroundColor(.gray)
                
                Toggle("Include time", isOn: $includeTime)
                    .foregroundColor(.gray)
            }
            .navigationTitle(editingCountdown != nil ? "Edit Countdown" : "New Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { 
                        editingCountdown = nil
                        dismiss() 
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingCountdown != nil ? "Save" : "Add") {
                        let countdown: Countdown
                        if let existing = editingCountdown {
                            countdown = Countdown(
                                id: existing.id,
                                title: title,
                                targetDate: targetDate,
                                isStarred: existing.isStarred
                            )
                            countdownManager.updateCountdown(existing, with: countdown)
                        } else {
                            countdown = Countdown(
                                title: title,
                                targetDate: targetDate,
                                isStarred: false
                            )
                            countdownManager.addCountdown(countdown)
                        }
                        editingCountdown = nil
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .onChange(of: editingCountdown) { oldValue, newValue in
            if let countdown = newValue {
                title = countdown.title
                targetDate = countdown.targetDate
                // Check if the target date has a non-zero time component
                let calendar = Calendar.current
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: countdown.targetDate)
                includeTime = timeComponents.hour != 0 || timeComponents.minute != 0 || timeComponents.second != 0
            }
        }
        .onAppear {
            // Set initial values if editing
            if let countdown = editingCountdown {
                title = countdown.title
                targetDate = countdown.targetDate
                // Check if the target date has a non-zero time component
                let calendar = Calendar.current
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: countdown.targetDate)
                includeTime = timeComponents.hour != 0 || timeComponents.minute != 0 || timeComponents.second != 0
            }
        }
    }
}

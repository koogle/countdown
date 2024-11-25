import SwiftUI
import CountdownShared

struct AddCountdownView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var countdownManager: CountdownManager
    
    @State private var title: String
    @State private var targetDate: Date
    @State private var includeTime: Bool
    
    let isEditing: Bool
    let editingCountdown: Countdown?
    
    init(countdownManager: CountdownManager, countdown: Countdown? = nil) {
        self.countdownManager = countdownManager
        self.editingCountdown = countdown
        self.isEditing = countdown != nil
        
        // Initialize state variables
        _title = State(initialValue: countdown?.title ?? "")
        _targetDate = State(initialValue: countdown?.targetDate ?? Date().addingTimeInterval(7*24*60*60))
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
            .navigationTitle(isEditing ? "Edit Countdown" : "New Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        let countdown: Countdown
                        if isEditing {
                            countdown = Countdown(
                                id: editingCountdown!.id,
                                title: title,
                                targetDate: targetDate,
                                isStarred: editingCountdown!.isStarred
                            )
                            countdownManager.updateCountdown(editingCountdown!, with: countdown)
                        } else {
                            countdown = Countdown(
                                title: title,
                                targetDate: targetDate,
                                isStarred: false
                            )
                            countdownManager.addCountdown(countdown)
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
} 
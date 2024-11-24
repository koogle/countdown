import SwiftUI

struct AddCountdownView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountdownViewModel
    
    @State private var title = ""
    @State private var targetDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                DatePicker("Target Date", selection: $targetDate, in: Date()...)
            }
            .navigationTitle("New Countdown")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    let countdown = Countdown(title: title, targetDate: targetDate)
                    viewModel.addCountdown(countdown)
                    dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
} 
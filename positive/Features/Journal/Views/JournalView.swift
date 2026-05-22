import SwiftUI

struct JournalView: View {
    @StateObject var journalStore: JournalStore
    @Environment("environment") var environment: Environment
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                if journalStore.journalEntries.isEmpty {
                    VStack {
                        Text("No journal entries yet.")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Tap the '+' button to create your first entry and start reflecting.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    List {
                        ForEach(journalStore.journalEntries) {
                            JournalRow(journalEntry: $0)
                        }
                        .onDelete(perform: journalStore.deleteJournalEntry)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Action to add new journal entry
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("Add new journal entry")
                }
            }
        }
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView(journalStore: JournalStore())
    }
}

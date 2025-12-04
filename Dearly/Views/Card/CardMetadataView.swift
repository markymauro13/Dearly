//
//  CardMetadataView.swift
//  Dearly
//
//  Created by Mark Mauro on 11/11/25.
//

import SwiftUI
import SwiftData

struct CardMetadataView: View {
    @Binding var card: Card
    @Environment(\.dismiss) private var dismiss
    
    @State private var sender: String
    @State private var occasion: String
    @State private var dateReceived: Date
    @State private var notes: String
    @State private var hasDateReceived: Bool
    
    let occasionOptions = [
        "Birthday",
        "Holiday",
        "Anniversary",
        "Thank You",
        "Just Because",
        "Get Well",
        "Sympathy",
        "Congratulations",
        "Love",
        "Friendship",
        "Other"
    ]
    
    init(card: Binding<Card>) {
        self._card = card
        _sender = State(initialValue: card.wrappedValue.sender ?? "")
        _occasion = State(initialValue: card.wrappedValue.occasion ?? "")
        _dateReceived = State(initialValue: card.wrappedValue.dateReceived ?? Date())
        _notes = State(initialValue: card.wrappedValue.notes ?? "")
        _hasDateReceived = State(initialValue: card.wrappedValue.dateReceived != nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Card Details")) {
                    HStack {
                        Text("From")
                        TextField("Who sent this card?", text: $sender)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Occasion", selection: $occasion) {
                        Text("Select...").tag("")
                        ForEach(occasionOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Toggle("Add date received", isOn: $hasDateReceived)
                    
                    if hasDateReceived {
                        DatePicker(
                            "Date Received",
                            selection: $dateReceived,
                            displayedComponents: .date
                        )
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Details")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMetadata()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveMetadata() {
        card.sender = sender.isEmpty ? nil : sender
        card.occasion = occasion.isEmpty ? nil : occasion
        card.dateReceived = hasDateReceived ? dateReceived : nil
        card.notes = notes.isEmpty ? nil : notes
    }
}

#Preview {
    CardMetadataView(card: .constant(Card()))
        .modelContainer(for: Card.self, inMemory: true)
}

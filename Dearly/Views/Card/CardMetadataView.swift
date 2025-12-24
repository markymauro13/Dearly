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
            ZStack {
                // Warm cream gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.98, blue: 0.96),  // Warm cream
                        Color(red: 0.99, green: 0.97, blue: 0.95), // Soft ivory
                        Color(red: 1.0, green: 0.99, blue: 0.98)   // Pearl white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Card Details Section
                        VStack(spacing: 0) {
                            // Section Header
                            HStack {
                                Text("Card Details")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0.40, green: 0.32, blue: 0.32))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                            
                            // From Field
                            VStack(spacing: 0) {
                                HStack {
                                    Text("From")
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.45))
                                    Spacer()
                                    TextField("Who sent this card?", text: $sender)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.25))
                                        .multilineTextAlignment(.trailing)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                
                                Divider()
                                    .padding(.leading, 16)
                            }
                            
                            // Occasion Picker
                            VStack(spacing: 0) {
                                Picker("Occasion", selection: $occasion) {
                                    Text("Select...").tag("")
                                    ForEach(occasionOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color(red: 0.85, green: 0.55, blue: 0.55))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                
                                Divider()
                                    .padding(.leading, 16)
                            }
                            
                            // Date Toggle
                            VStack(spacing: 0) {
                                Toggle("Add date received", isOn: $hasDateReceived)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.45))
                                    .tint(Color(red: 0.85, green: 0.55, blue: 0.55))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                
                                if hasDateReceived {
                                    Divider()
                                        .padding(.leading, 16)
                                    
                                    DatePicker(
                                        "Date Received",
                                        selection: $dateReceived,
                                        displayedComponents: .date
                                    )
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.45))
                                    .tint(Color(red: 0.85, green: 0.55, blue: 0.55))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color(red: 0.5, green: 0.4, blue: 0.4).opacity(0.08), radius: 8, x: 0, y: 4)
                        )
                        
                        // Notes Section
                        VStack(spacing: 0) {
                            // Section Header
                            HStack {
                                Text("Notes")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0.40, green: 0.32, blue: 0.32))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                            
                            // Notes Text Editor
                            ZStack(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text("Add notes about this card...")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(Color(red: 0.7, green: 0.65, blue: 0.65))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                }
                                
                                TextEditor(text: $notes)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.25))
                                    .frame(minHeight: 120)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                            }
                            .padding(.bottom, 12)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color(red: 0.5, green: 0.4, blue: 0.4).opacity(0.08), radius: 8, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Edit Details")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Details")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.40, green: 0.32, blue: 0.32))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.45))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMetadata()
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.55))
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

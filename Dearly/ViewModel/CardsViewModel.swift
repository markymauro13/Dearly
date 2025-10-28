//
//  CardsViewModel.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import Foundation
import SwiftUI

enum SortOption: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case favorites = "Favorites"
}

@MainActor
class CardsViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isShowingScanner = false
    @Published var sortOption: SortOption = .newest
    
    private let userDefaultsKey = "savedCards"
    
    init() {
        loadCards()
    }
    
    // MARK: - Public Methods
    
    var sortedCards: [Card] {
        switch sortOption {
        case .newest:
            return cards.sorted { $0.dateScanned > $1.dateScanned }
        case .oldest:
            return cards.sorted { $0.dateScanned < $1.dateScanned }
        case .favorites:
            return cards.filter { $0.isFavorite }
        }
    }
    
    func addCard(_ card: Card) {
        cards.insert(card, at: 0) // Add to beginning for newest first
        saveCards()
    }
    
    func deleteCard(_ card: Card) {
        cards.removeAll { $0.id == card.id }
        saveCards()
    }
    
    func updateCard(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
            saveCards()
        }
    }
    
    func toggleFavorite(for card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFavorite.toggle()
            saveCards()
        }
    }
    
    // MARK: - Private Methods
    
    private func saveCards() {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadCards() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Card].self, from: data) {
            cards = decoded
        }
    }
}


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
    @Published var selectedOccasionFilter: String? = nil
    
    private let repository: CardRepositoryProtocol
    
    init(repository: CardRepositoryProtocol = CardRepository()) {
        self.repository = repository
        loadCards()
    }
    
    // MARK: - Public Methods
    
    var sortedCards: [Card] {
        let filtered = filteredCards
        switch sortOption {
        case .newest:
            return filtered.sorted { $0.dateScanned > $1.dateScanned }
        case .oldest:
            return filtered.sorted { $0.dateScanned < $1.dateScanned }
        case .favorites:
            return filtered.filter { $0.isFavorite }
        }
    }
    
    private var filteredCards: [Card] {
        // Filter by occasion if selected
        if let occasionFilter = selectedOccasionFilter {
            return cards.filter { $0.occasion == occasionFilter }
        }
        return cards
    }
    
    var availableOccasions: [String] {
        let occasions = cards.compactMap { $0.occasion }
        return Array(Set(occasions)).sorted()
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
        repository.saveCards(cards)
    }
    
    private func loadCards() {
        cards = repository.loadCards()
    }
}


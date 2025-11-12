//
//  CardRepository.swift
//  Dearly
//
//  Created by Mark Mauro on 11/12/25.
//

import Foundation

protocol CardRepositoryProtocol {
    func loadCards() -> [Card]
    func saveCards(_ cards: [Card])
}

class CardRepository: CardRepositoryProtocol {
    private let userDefaultsKey = "savedCards"
    
    func loadCards() -> [Card] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([Card].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func saveCards(_ cards: [Card]) {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}


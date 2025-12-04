//
//  CardRepository.swift
//  Dearly
//
//  Created by Mark Mauro on 11/12/25.
//

import Foundation
import SwiftData

/// Repository for managing Card persistence with SwiftData
/// Handles coordination between SwiftData and ImageStorageService
final class CardRepository {
    private let modelContext: ModelContext
    private let imageStorage: ImageStorageService
    
    init(modelContext: ModelContext, imageStorage: ImageStorageService = .shared) {
        self.modelContext = modelContext
        self.imageStorage = imageStorage
    }
    
    // MARK: - CRUD Operations
    
    /// Fetches all cards from the database
    func fetchAllCards() -> [Card] {
        let descriptor = FetchDescriptor<Card>(
            sortBy: [SortDescriptor(\.dateScanned, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch cards: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Adds a new card to the database
    func addCard(_ card: Card) {
        modelContext.insert(card)
        save()
    }
    
    /// Updates an existing card (SwiftData tracks changes automatically)
    func updateCard() {
        save()
    }
    
    /// Deletes a card and its associated images
    func deleteCard(_ card: Card) {
        // Delete images from file system first
        imageStorage.deleteImages(for: card.id)
        
        // Delete from database
        modelContext.delete(card)
        save()
    }
    
    /// Saves pending changes to the database
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("❌ Failed to save context: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Image Operations
    
    /// Saves images for a card and returns the file paths
    func saveImages(
        frontImage: UIImage?,
        backImage: UIImage?,
        insideLeftImage: UIImage?,
        insideRightImage: UIImage?,
        for cardId: UUID
    ) -> (front: String?, back: String?, insideLeft: String?, insideRight: String?) {
        let frontPath = frontImage.flatMap { imageStorage.saveImage($0, for: cardId, side: .front) }
        let backPath = backImage.flatMap { imageStorage.saveImage($0, for: cardId, side: .back) }
        let insideLeftPath = insideLeftImage.flatMap { imageStorage.saveImage($0, for: cardId, side: .insideLeft) }
        let insideRightPath = insideRightImage.flatMap { imageStorage.saveImage($0, for: cardId, side: .insideRight) }
        
        return (frontPath, backPath, insideLeftPath, insideRightPath)
    }
    
    // MARK: - Utility
    
    /// Clears all cards and their images (for testing/reset)
    func clearAllData() {
        let cards = fetchAllCards()
        for card in cards {
            deleteCard(card)
        }
        imageStorage.clearAllImages()
    }
}

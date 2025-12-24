//
//  Card.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Card {
    var id: UUID
    var frontImagePath: String?
    var backImagePath: String?
    var insideLeftImagePath: String?
    var insideRightImagePath: String?
    var dateScanned: Date
    var isFavorite: Bool
    
    // Metadata
    var sender: String?
    var occasion: String?
    var dateReceived: Date?
    var notes: String?
    
    init(
        id: UUID = UUID(),
        frontImagePath: String? = nil,
        backImagePath: String? = nil,
        insideLeftImagePath: String? = nil,
        insideRightImagePath: String? = nil,
        dateScanned: Date = Date(),
        isFavorite: Bool = false,
        sender: String? = nil,
        occasion: String? = nil,
        dateReceived: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.frontImagePath = frontImagePath
        self.backImagePath = backImagePath
        self.insideLeftImagePath = insideLeftImagePath
        self.insideRightImagePath = insideRightImagePath
        self.dateScanned = dateScanned
        self.isFavorite = isFavorite
        self.sender = sender
        self.occasion = occasion
        self.dateReceived = dateReceived
        self.notes = notes
    }
    
    // MARK: - Computed Properties for Image Loading
    
    var frontImage: UIImage? {
        ImageStorageService.shared.loadImage(from: frontImagePath)
    }
    
    var backImage: UIImage? {
        ImageStorageService.shared.loadImage(from: backImagePath)
    }
    
    var insideLeftImage: UIImage? {
        ImageStorageService.shared.loadImage(from: insideLeftImagePath)
    }
    
    var insideRightImage: UIImage? {
        ImageStorageService.shared.loadImage(from: insideRightImagePath)
    }
}

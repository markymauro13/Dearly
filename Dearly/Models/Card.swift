//
//  Card.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import Foundation
import SwiftUI

struct Card: Identifiable, Codable {
    let id: UUID
    var frontImageData: Data?
    var backImageData: Data?
    var insideLeftImageData: Data?
    var insideRightImageData: Data?
    var dateScanned: Date
    var isFavorite: Bool
    
    // Metadata
    var sender: String?
    var occasion: String?
    var dateReceived: Date?
    var notes: String?
    
    init(
        id: UUID = UUID(),
        frontImageData: Data? = nil,
        backImageData: Data? = nil,
        insideLeftImageData: Data? = nil,
        insideRightImageData: Data? = nil,
        dateScanned: Date = Date(),
        isFavorite: Bool = false,
        sender: String? = nil,
        occasion: String? = nil,
        dateReceived: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.frontImageData = frontImageData
        self.backImageData = backImageData
        self.insideLeftImageData = insideLeftImageData
        self.insideRightImageData = insideRightImageData
        self.dateScanned = dateScanned
        self.isFavorite = isFavorite
        self.sender = sender
        self.occasion = occasion
        self.dateReceived = dateReceived
        self.notes = notes
    }
    
    // Helper to get UIImage from stored data
    var frontImage: UIImage? {
        guard let data = frontImageData else { return nil }
        return UIImage(data: data)
    }
    
    var backImage: UIImage? {
        guard let data = backImageData else { return nil }
        return UIImage(data: data)
    }
    
    var insideLeftImage: UIImage? {
        guard let data = insideLeftImageData else { return nil }
        return UIImage(data: data)
    }
    
    var insideRightImage: UIImage? {
        guard let data = insideRightImageData else { return nil }
        return UIImage(data: data)
    }
}


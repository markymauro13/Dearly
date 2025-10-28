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
    var insideSpreadImageData: Data?
    var dateScanned: Date
    var isFavorite: Bool
    
    init(
        id: UUID = UUID(),
        frontImageData: Data? = nil,
        insideSpreadImageData: Data? = nil,
        dateScanned: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.frontImageData = frontImageData
        self.insideSpreadImageData = insideSpreadImageData
        self.dateScanned = dateScanned
        self.isFavorite = isFavorite
    }
    
    // Helper to get UIImage from stored data
    var frontImage: UIImage? {
        guard let data = frontImageData else { return nil }
        return UIImage(data: data)
    }
    
    var insideSpreadImage: UIImage? {
        guard let data = insideSpreadImageData else { return nil }
        return UIImage(data: data)
    }
}


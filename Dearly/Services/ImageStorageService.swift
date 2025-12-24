//
//  ImageStorageService.swift
//  Dearly
//
//  Created by Mark Mauro on 12/4/25.
//

import Foundation
import UIKit

/// Enumeration representing the different sides of a card for image storage
enum ImageSide: String {
    case front = "front"
    case back = "back"
    case insideLeft = "insideLeft"
    case insideRight = "insideRight"
}

/// Service responsible for storing and retrieving card images from the file system
final class ImageStorageService {
    
    /// Shared singleton instance
    static let shared = ImageStorageService()
    
    /// FileManager instance for file operations
    private let fileManager = FileManager.default
    
    /// JPEG compression quality for saved images (0.0 - 1.0)
    private let compressionQuality: CGFloat = 0.8
    
    /// Base directory for storing card images
    private var imagesDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("CardImages", isDirectory: true)
    }
    
    // MARK: - Initialization
    
    private init() {
        createImagesDirectoryIfNeeded()
    }
    
    // MARK: - Public Methods
    
    /// Saves an image to the file system for a specific card and side
    /// - Parameters:
    ///   - image: The UIImage to save
    ///   - cardId: The unique identifier of the card
    ///   - side: The side of the card (front, back, etc.)
    /// - Returns: The relative file path if successful, nil otherwise
    func saveImage(_ image: UIImage, for cardId: UUID, side: ImageSide) -> String? {
        // Create card-specific directory
        let cardDirectory = imagesDirectory.appendingPathComponent(cardId.uuidString, isDirectory: true)
        
        do {
            if !fileManager.fileExists(atPath: cardDirectory.path) {
                try fileManager.createDirectory(at: cardDirectory, withIntermediateDirectories: true)
            }
        } catch {
            print("❌ Failed to create card directory: \(error.localizedDescription)")
            return nil
        }
        
        // Generate file path
        let fileName = "\(side.rawValue).jpg"
        let filePath = cardDirectory.appendingPathComponent(fileName)
        
        // Compress and save image
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            print("❌ Failed to convert image to JPEG data")
            return nil
        }
        
        do {
            try imageData.write(to: filePath)
            // Return relative path for storage in database
            return "CardImages/\(cardId.uuidString)/\(fileName)"
        } catch {
            print("❌ Failed to save image: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Loads an image from a relative file path
    /// - Parameter relativePath: The relative path to the image file
    /// - Returns: The UIImage if found and loadable, nil otherwise
    func loadImage(from relativePath: String?) -> UIImage? {
        guard let relativePath = relativePath else { return nil }
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullPath = documentsDirectory.appendingPathComponent(relativePath)
        
        guard fileManager.fileExists(atPath: fullPath.path) else {
            print("⚠️ Image file not found at: \(fullPath.path)")
            return nil
        }
        
        return UIImage(contentsOfFile: fullPath.path)
    }
    
    /// Deletes all images associated with a card
    /// - Parameter cardId: The unique identifier of the card
    func deleteImages(for cardId: UUID) {
        let cardDirectory = imagesDirectory.appendingPathComponent(cardId.uuidString, isDirectory: true)
        
        do {
            if fileManager.fileExists(atPath: cardDirectory.path) {
                try fileManager.removeItem(at: cardDirectory)
                print("✅ Deleted images for card: \(cardId)")
            }
        } catch {
            print("❌ Failed to delete images for card \(cardId): \(error.localizedDescription)")
        }
    }
    
    /// Gets the full URL for an image path
    /// - Parameter relativePath: The relative path to the image
    /// - Returns: The full URL to the image file
    func getImageURL(for relativePath: String?) -> URL? {
        guard let relativePath = relativePath else { return nil }
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(relativePath)
    }
    
    /// Checks if an image exists at the given path
    /// - Parameter relativePath: The relative path to check
    /// - Returns: True if the image exists, false otherwise
    func imageExists(at relativePath: String?) -> Bool {
        guard let relativePath = relativePath else { return false }
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullPath = documentsDirectory.appendingPathComponent(relativePath)
        
        return fileManager.fileExists(atPath: fullPath.path)
    }
    
    /// Clears all stored card images (useful for testing/reset)
    func clearAllImages() {
        do {
            if fileManager.fileExists(atPath: imagesDirectory.path) {
                try fileManager.removeItem(at: imagesDirectory)
                createImagesDirectoryIfNeeded()
                print("✅ Cleared all card images")
            }
        } catch {
            print("❌ Failed to clear images: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Creates the base images directory if it doesn't exist
    private func createImagesDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            do {
                try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
                print("✅ Created CardImages directory")
            } catch {
                print("❌ Failed to create CardImages directory: \(error.localizedDescription)")
            }
        }
    }
}


//
//  PerformanceMonitor.swift
//  Dearly
//
//  Created by Mark Mauro on 12/4/25.
//

import Foundation
import UIKit

/// Service for monitoring app performance metrics
final class PerformanceMonitor {
    
    static let shared = PerformanceMonitor()
    
    private init() {}
    
    // MARK: - Memory Usage
    
    /// Gets current memory usage in megabytes
    func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            return 0
        }
        
        let usedBytes = Double(info.resident_size)
        return usedBytes / 1024.0 / 1024.0 // Convert to MB
    }
    
    /// Gets peak memory usage since app launch
    func getPeakMemoryUsage() -> Double {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(TASK_VM_INFO),
                         $0,
                         &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return 0
        }
        
        let peakBytes = Double(info.phys_footprint)
        return peakBytes / 1024.0 / 1024.0 // Convert to MB
    }
    
    // MARK: - Storage Usage
    
    /// Calculates total storage used by card images
    func getImageStorageSize() -> Double {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDirectory = documentsDirectory.appendingPathComponent("CardImages", isDirectory: true)
        
        guard fileManager.fileExists(atPath: imagesDirectory.path) else {
            return 0
        }
        
        var totalSize: UInt64 = 0
        
        if let enumerator = fileManager.enumerator(at: imagesDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let fileSize = resourceValues.fileSize {
                    totalSize += UInt64(fileSize)
                }
            }
        }
        
        return Double(totalSize) / 1024.0 / 1024.0 // Convert to MB
    }
    
    /// Gets the number of image files stored
    func getImageFileCount() -> Int {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDirectory = documentsDirectory.appendingPathComponent("CardImages", isDirectory: true)
        
        guard fileManager.fileExists(atPath: imagesDirectory.path) else {
            return 0
        }
        
        var count = 0
        
        if let enumerator = fileManager.enumerator(at: imagesDirectory, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "jpg" {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    /// Calculates the size of the app bundle (the .app itself)
    func getAppBundleSize() -> Double {
        guard let bundlePath = Bundle.main.bundlePath as String? else {
            return 0
        }
        
        let bundleURL = URL(fileURLWithPath: bundlePath)
        return getDirectorySize(at: bundleURL)
    }
    
    /// Calculates the size of the Documents directory (all user data)
    func getDocumentsDirectorySize() -> Double {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return 0
        }
        
        return getDirectorySize(at: documentsDirectory)
    }
    
    /// Calculates total app size (bundle + user data)
    func getTotalAppSize() -> Double {
        return getAppBundleSize() + getDocumentsDirectorySize()
    }
    
    /// Helper method to calculate directory size recursively
    private func getDirectorySize(at url: URL) -> Double {
        let fileManager = FileManager.default
        var totalSize: UInt64 = 0
        
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey]) {
            for case let fileURL as URL in enumerator {
                do {
                    let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                    
                    // Only count files, not directories
                    if let isDirectory = resourceValues.isDirectory, !isDirectory {
                        if let fileSize = resourceValues.fileSize {
                            totalSize += UInt64(fileSize)
                        }
                    }
                } catch {
                    // Skip files we can't read
                    continue
                }
            }
        }
        
        return Double(totalSize) / 1024.0 / 1024.0 // Convert to MB
    }
    
    // MARK: - Performance Metrics
    
    /// Measures time to execute a block of code
    func measureTime(_ block: () -> Void) -> TimeInterval {
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let endTime = CFAbsoluteTimeGetCurrent()
        return endTime - startTime
    }
    
    /// Formats bytes to human-readable string
    func formatBytes(_ bytes: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes * 1024 * 1024))
    }
}


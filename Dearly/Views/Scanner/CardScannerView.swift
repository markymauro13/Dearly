//
//  CardScannerView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI
import VisionKit

struct CardScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onScanComplete: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: CardScannerView
        
        init(parent: CardScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var scannedImages: [UIImage] = []
            
            for i in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: i)
                scannedImages.append(image)
            }
            
            parent.onScanComplete(scannedImages)
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document scanning failed with error: \(error.localizedDescription)")
            controller.dismiss(animated: true)
        }
    }
}


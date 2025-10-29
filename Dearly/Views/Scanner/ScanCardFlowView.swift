//
//  ScanCardFlowView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct ScanCardFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CardsViewModel
    
    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @State private var insideLeftImage: UIImage?
    @State private var insideRightImage: UIImage?
    @State private var showScanner = false
    
    private var isComplete: Bool {
        frontImage != nil && backImage != nil && insideLeftImage != nil && insideRightImage != nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Text("Scan Your Card")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Capture all four sides of your card in a single session. Please scan in the following order: Front, Back, Inside Left, then Inside Right.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ImagePreview(image: $frontImage, label: "Front")
                        ImagePreview(image: $backImage, label: "Back")
                    }
                    HStack(spacing: 12) {
                        ImagePreview(image: $insideLeftImage, label: "Inside Left")
                        ImagePreview(image: $insideRightImage, label: "Inside Right")
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    showScanner = true
                }) {
                    Label("Scan Card", systemImage: "camera.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .navigationTitle("New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveCard()
                    }
                    .disabled(!isComplete)
                }
            }
            .sheet(isPresented: $showScanner) {
                CardScannerView { images in
                    handleScannedImages(images)
                }
            }
        }
    }
    
    private func handleScannedImages(_ images: [UIImage]) {
        guard images.count >= 4 else {
            // Handle error: not enough images scanned
            print("Error: Expected 4 images, but received \(images.count)")
            return
        }

        frontImage = images[0]
        backImage = images[1]
        insideLeftImage = images[2]
        insideRightImage = images[3]
    }
    
    private func saveCard() {
        let card = Card(
            frontImageData: frontImage?.jpegData(compressionQuality: 0.8),
            backImageData: backImage?.jpegData(compressionQuality: 0.8),
            insideLeftImageData: insideLeftImage?.jpegData(compressionQuality: 0.8),
            insideRightImageData: insideRightImage?.jpegData(compressionQuality: 0.8)
        )
        
        viewModel.addCard(card)
        dismiss()
    }
}

struct ImagePreview: View {
    @Binding var image: UIImage?
    let label: String

    var body: some View {
        VStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                    .shadow(radius: 4)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        Image(systemName: "photo.on.rectangle")
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.5))
                    )
            }

            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ScanCardFlowView(viewModel: CardsViewModel())
}


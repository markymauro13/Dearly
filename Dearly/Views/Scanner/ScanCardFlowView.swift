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
                VStack(spacing: 8) {
                    Text("Scan Your Card")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    
                    Text("Capture all four sides of your card in a single session. Please scan in the following order: Front, Back, Inside Left, then Inside Right.")
                        .font(.system(.subheadline, design: .rounded))
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
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.42, green: 0.67, blue: 1.0),
                                    Color(red: 0.35, green: 0.60, blue: 0.95)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.42, green: 0.67, blue: 1.0).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .navigationTitle("New Card")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
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
        
        // Always switch to "Newest" so user sees their newly scanned card
        viewModel.sortOption = .newest
        viewModel.selectedOccasionFilter = nil  // Also clear any occasion filter
        
        dismiss()
    }
}

struct ImagePreview: View {
    @Binding var image: UIImage?
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.97, green: 0.97, blue: 0.98),
                                Color.white
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1.5)
                    )
                    .overlay(
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.4))
                    )
            }

            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black.opacity(0.7))
        }
    }
}

#Preview {
    ScanCardFlowView(viewModel: CardsViewModel())
}


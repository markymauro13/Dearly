//
//  ScanCardFlowView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

enum ScanStep: String, CaseIterable {
    case front = "Front Cover"
    case insideSpread = "Inside Spread"
    
    var instruction: String {
        switch self {
        case .front:
            return "Scan the front cover (closed)"
        case .insideSpread:
            return "Open fully and scan both inside pages together as one wide image"
        }
    }
    
    var detailInstruction: String {
        switch self {
        case .front:
            return "Keep the card portrait orientation"
        case .insideSpread:
            return "Keep the same height, but capture both pages side-by-side"
        }
    }
}

struct ScanCardFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CardsViewModel
    
    @State private var currentStep: ScanStep = .front
    @State private var frontImage: UIImage?
    @State private var insideSpreadImage: UIImage?
    @State private var showScanner = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Title
                Text("Scan Card")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                Spacer()
                
                // Current step label and instruction
                VStack(spacing: 8) {
                    Text(currentStep.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(currentStep.instruction)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text(currentStep.detailInstruction)
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .italic()
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Image preview
                if let image = currentStepImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 400)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(maxWidth: 300, maxHeight: 400)
                        .overlay(
                            Text("No scan yet")
                                .foregroundColor(.gray)
                        )
                }
                
                Spacer()
                
                // Camera button
                Button(action: {
                    showScanner = true
                }) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .padding(.bottom, 40)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isCurrentStepComplete {
                        Button(isLastStep ? "Done" : "Next") {
                            if isLastStep {
                                saveCard()
                            } else {
                                moveToNextStep()
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                CardScannerView { images in
                    if let firstImage = images.first {
                        setCurrentStepImage(firstImage)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var currentStepImage: UIImage? {
        switch currentStep {
        case .front: return frontImage
        case .insideSpread: return insideSpreadImage
        }
    }
    
    private var isCurrentStepComplete: Bool {
        currentStepImage != nil
    }
    
    private var isLastStep: Bool {
        currentStep == .insideSpread
    }
    
    // MARK: - Helper Methods
    
    private func setCurrentStepImage(_ image: UIImage) {
        switch currentStep {
        case .front: frontImage = image
        case .insideSpread: insideSpreadImage = image
        }
    }
    
    private func moveToNextStep() {
        guard let currentIndex = ScanStep.allCases.firstIndex(of: currentStep),
              currentIndex < ScanStep.allCases.count - 1 else {
            return
        }
        currentStep = ScanStep.allCases[currentIndex + 1]
    }
    
    private func saveCard() {
        let card = Card(
            frontImageData: frontImage?.jpegData(compressionQuality: 0.8),
            insideSpreadImageData: insideSpreadImage?.jpegData(compressionQuality: 0.8)
        )
        
        viewModel.addCard(card)
        dismiss()
    }
}

#Preview {
    ScanCardFlowView(viewModel: CardsViewModel())
}


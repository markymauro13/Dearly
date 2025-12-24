//
//  PerformanceTestView.swift
//  Dearly
//
//  Created by Mark Mauro on 12/4/25.
//

import SwiftUI
import SwiftData

struct PerformanceTestView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CardsViewModel
    
    @State private var currentMemory: Double = 0
    @State private var peakMemory: Double = 0
    @State private var storageSize: Double = 0
    @State private var imageFileCount: Int = 0
    @State private var appBundleSize: Double = 0
    @State private var documentsSize: Double = 0
    @State private var totalAppSize: Double = 0
    @State private var isGenerating = false
    @State private var generationProgress: Double = 0
    @State private var lastGenerationTime: TimeInterval = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Real-Time Metrics
                    metricsSection
                    
                    // MARK: - Card Statistics
                    statisticsSection
                    
                    // MARK: - Load Testing
                    loadTestingSection
                    
                    // MARK: - Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Performance Testing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                updateMetrics()
            }
            .onReceive(timer) { _ in
                if !isGenerating {
                    updateMetrics()
                }
            }
            .alert("Load Test Complete", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Metrics Section
    
    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("Real-Time Metrics")
                    .font(.headline)
                Spacer()
                Button(action: updateMetrics) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
            }
            
            VStack(spacing: 12) {
                MetricRow(
                    icon: "memorychip",
                    label: "Current Memory",
                    value: String(format: "%.2f MB", currentMemory),
                    color: memoryColor(currentMemory)
                )
                
                MetricRow(
                    icon: "chart.bar.fill",
                    label: "Peak Memory",
                    value: String(format: "%.2f MB", peakMemory),
                    color: memoryColor(peakMemory)
                )
                
                MetricRow(
                    icon: "externaldrive",
                    label: "Image Storage",
                    value: String(format: "%.2f MB", storageSize),
                    color: storageColor(storageSize)
                )
                
                MetricRow(
                    icon: "photo.stack",
                    label: "Image Files",
                    value: "\(imageFileCount) files",
                    color: .purple
                )
                
                Divider()
                    .padding(.vertical, 4)
                
                MetricRow(
                    icon: "app.badge",
                    label: "App Bundle",
                    value: String(format: "%.2f MB", appBundleSize),
                    color: .cyan
                )
                
                MetricRow(
                    icon: "doc.on.doc",
                    label: "User Data",
                    value: String(format: "%.2f MB", documentsSize),
                    color: .indigo
                )
                
                MetricRow(
                    icon: "square.stack.3d.up",
                    label: "Total App Size",
                    value: String(format: "%.2f MB", totalAppSize),
                    color: appSizeColor(totalAppSize)
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie")
                    .foregroundColor(.green)
                Text("Card Statistics")
                    .font(.headline)
            }
            
            VStack(spacing: 12) {
                StatRow(label: "Total Cards", value: "\(viewModel.cards.count)")
                StatRow(label: "Favorites", value: "\(viewModel.favoriteCards.count)")
                StatRow(label: "Avg Storage/Card", value: averageStoragePerCard)
                StatRow(label: "Images/Card", value: averageImagesPerCard)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Load Testing Section
    
    private var loadTestingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)
                Text("Load Testing")
                    .font(.headline)
            }
            
            if isGenerating {
                VStack(spacing: 12) {
                    ProgressView(value: generationProgress, total: 1.0)
                    Text("\(Int(generationProgress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    LoadTestButton(count: 10, action: { generateCards(count: 10) })
                    LoadTestButton(count: 50, action: { generateCards(count: 50) })
                    LoadTestButton(count: 100, action: { generateCards(count: 100) })
                    LoadTestButton(count: 500, action: { generateCards(count: 500) })
                    
                    if lastGenerationTime > 0 {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("Last generation: \(String(format: "%.2f", lastGenerationTime))s")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Actions Section
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "gearshape.2")
                    .foregroundColor(.red)
                Text("Quick Actions")
                    .font(.headline)
            }
            
            VStack(spacing: 12) {
                Button(action: clearAllData) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear All Cards & Images")
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                
                Button(action: forceGarbageCollection) {
                    HStack {
                        Image(systemName: "arrow.3.trianglepath")
                        Text("Force Memory Cleanup")
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func memoryColor(_ mb: Double) -> Color {
        if mb < 100 { return .green }
        if mb < 200 { return .orange }
        return .red
    }
    
    private func storageColor(_ mb: Double) -> Color {
        if mb < 50 { return .green }
        if mb < 200 { return .orange }
        return .red
    }
    
    private func appSizeColor(_ mb: Double) -> Color {
        if mb < 100 { return .green }
        if mb < 250 { return .orange }
        return .red
    }
    
    private var averageStoragePerCard: String {
        guard viewModel.cards.count > 0 else { return "0 MB" }
        let avg = storageSize / Double(viewModel.cards.count)
        return String(format: "%.2f MB", avg)
    }
    
    private var averageImagesPerCard: String {
        guard viewModel.cards.count > 0 else { return "0" }
        let avg = Double(imageFileCount) / Double(viewModel.cards.count)
        return String(format: "%.1f", avg)
    }
    
    // MARK: - Actions
    
    private func updateMetrics() {
        currentMemory = PerformanceMonitor.shared.getMemoryUsage()
        peakMemory = PerformanceMonitor.shared.getPeakMemoryUsage()
        storageSize = PerformanceMonitor.shared.getImageStorageSize()
        imageFileCount = PerformanceMonitor.shared.getImageFileCount()
        appBundleSize = PerformanceMonitor.shared.getAppBundleSize()
        documentsSize = PerformanceMonitor.shared.getDocumentsDirectorySize()
        totalAppSize = PerformanceMonitor.shared.getTotalAppSize()
    }
    
    private func generateCards(count: Int) {
        isGenerating = true
        generationProgress = 0
        
        let startMemory = currentMemory
        
        let duration = PerformanceMonitor.shared.measureTime {
            let batchSize = 10
            let batches = (count + batchSize - 1) / batchSize
            
            for batch in 0..<batches {
                let cardsInBatch = min(batchSize, count - (batch * batchSize))
                
                for _ in 0..<cardsInBatch {
                    let colors: [UIColor] = [
                        UIColor(red: 0.75, green: 0.65, blue: 1.0, alpha: 1.0),
                        UIColor(red: 1.0, green: 0.54, blue: 0.54, alpha: 1.0),
                        UIColor(red: 0.42, green: 0.67, blue: 1.0, alpha: 1.0),
                        UIColor(red: 0.66, green: 0.90, blue: 0.81, alpha: 1.0)
                    ]
                    
                    let _ = viewModel.addCard(
                        frontImage: createTestImage(color: colors.randomElement() ?? .systemBlue, text: "F"),
                        backImage: createTestImage(color: colors.randomElement() ?? .systemPink, text: "B"),
                        insideLeftImage: createTestImage(color: colors.randomElement() ?? .systemPurple, text: "IL"),
                        insideRightImage: createTestImage(color: colors.randomElement() ?? .systemTeal, text: "IR"),
                        sender: "Test User",
                        occasion: "Testing"
                    )
                }
                
                generationProgress = Double(batch + 1) / Double(batches)
            }
        }
        
        lastGenerationTime = duration
        updateMetrics()
        
        let endMemory = currentMemory
        let memoryDelta = endMemory - startMemory
        let avgTimePerCard = duration / Double(count)
        
        alertMessage = """
        Generated \(count) cards
        
        Time: \(String(format: "%.2f", duration))s
        Avg: \(String(format: "%.3f", avgTimePerCard))s per card
        
        Memory: \(String(format: "%.2f", memoryDelta)) MB increase
        Storage: \(String(format: "%.2f", storageSize)) MB total
        Total App Size: \(String(format: "%.2f", totalAppSize)) MB
        """
        
        isGenerating = false
        showAlert = true
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
    }
    
    private func createTestImage(color: UIColor, text: String) -> UIImage {
        let size = CGSize(width: 600, height: 840)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 120, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.3)
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func clearAllData() {
        viewModel.clearAllData()
        updateMetrics()
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
    }
    
    private func forceGarbageCollection() {
        // Force deallocation of cached images
        updateMetrics()
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

// MARK: - Supporting Views

struct MetricRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(color)
                .fontWeight(.semibold)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
                .fontWeight(.medium)
        }
    }
}

struct LoadTestButton: View {
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Generate \(count) Cards")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .foregroundColor(.primary)
            .cornerRadius(10)
        }
    }
}

// MARK: - Preview

#Preview {
    PerformanceTestView(viewModel: CardsViewModel())
        .modelContainer(for: Card.self, inMemory: true)
}


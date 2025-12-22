# Dearly 💌

A beautiful iOS app for preserving and cherishing greeting cards from loved ones. Scan, store, and relive your special moments forever.

## Overview

Dearly transforms physical greeting cards into digital memories that you can keep forever. With elegant 3D animations and thoughtful organization features, it's like having all your cherished cards in your pocket.

## ✨ Current Features

### Card Scanning

- ✅ Document camera integration for high-quality scans
- ✅ Support for folding cards (4 sides: front, back, inside left, inside right)
- ✅ Support for flat cards (2 sides: front, back)
- ✅ Guided scanning flow with progress indicators
- ✅ Retake capability for each side
- ✅ Celebration animation after successful save

### Card Management

- ✅ Grid view with thumbnail previews
- ✅ SwiftData persistence with file-based image storage
- ✅ Sort by: Newest, Oldest, Favorites
- ✅ Filter by occasion
- ✅ Favorite marking with visual indicators
- ✅ Delete with confirmation
- ✅ Empty state with elegant design

### Card Viewing

- ✅ Immersive full-screen detail view
- ✅ Interactive 3D card animation
  - Tap to open/close
  - Drag to rotate
  - Pinch to zoom
  - Double-tap to reset
- ✅ Page selector (Front, Back, Outside, Inside)
- ✅ Frosted glass UI elements
- ✅ Floating particle effects

### Metadata

- ✅ Sender name
- ✅ Occasion selection (Birthday, Holiday, Anniversary, etc.)
- ✅ Date received
- ✅ Personal notes
- ✅ Editable metadata sheet

### Onboarding

- ✅ Multi-page onboarding flow
- ✅ Feature highlights with icons
- ✅ Category badges explaining occasions
- ✅ Skip/continue navigation

### Technical Features

- ✅ SwiftData for metadata persistence (iOS 17+)
- ✅ FileManager for efficient image storage
- ✅ JPEG compression (80% quality)
- ✅ Organized file structure: `Documents/CardImages/{cardId}/`
- ✅ Automatic image cleanup on card deletion
- ✅ MVVM architecture
- ✅ Repository pattern for data access

## 🚧 Planned Features

### Phase 1: Core Enhancements

- [X] Search functionality (by sender, occasion, notes)
- [X] Multiple cards selection and bulk actions
- [ ] Card duplication
- [ ] Export individual cards or collections
- [ ] Share cards via Messages, Email, AirDrop

### Phase 2: Organization

- [ ] Collections/albums for grouping cards
- [ ] Tags system for better organization
- [ ] Timeline view by date received
- [ ] Year-over-year comparison

### Phase 3: Social & Memories

- [ ] Reminders for important dates
- [ ] Memory lane: "Cards from this day X years ago"
- [ ] Greeting card statistics (most common occasions, senders, etc.)
- [ ] iCloud sync across devices

### Phase 4: Advanced Features

- [ ] OCR text extraction from cards
- [ ] Handwriting recognition
- [ ] Video message attachments
- [ ] Voice note attachments
- [ ] Apple Watch complications for quick access

### Phase 5: Sharing & Community

- [ ] Family sharing
- [ ] Create digital thank-you responses
- [ ] Print physical copies from app

## 🛠 Technical Stack

### Platform

- **iOS**: 17.6+
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData + FileManager

### Architecture

```
┌─────────────────────────────────────┐
│           Views (SwiftUI)            │
│  • HomeView                          │
│  • ScanCardFlowView                  │
│  • CardDetailView                    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        ViewModel Layer               │
│  • CardsViewModel (@Observable)      │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Repository Layer               │
│  • CardRepository (SwiftData)        │
│  • ImageStorageService (FileManager) │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Data Layer                   │
│  • Card (@Model)                     │
│  • SwiftData ModelContainer          │
│  • File System (JPEG images)         │
└──────────────────────────────────────┘
```

### Key Components

#### Models

- `Card`: SwiftData model with file paths to images

#### Services

- `ImageStorageService`: Manages image save/load/delete operations
- `CardRepository`: Coordinates SwiftData and ImageStorageService

#### Views

- `HomeView`: Main grid view with sorting/filtering
- `ScanCardFlowView`: Multi-step scanning workflow
- `CardDetailView`: Immersive 3D card viewer
- `AnimatedCardView`: 3D card with gestures
- `OnboardingView`: First-time user experience

## 📱 Requirements

- **iOS**: 17.6 or later
- **Device**: iPhone or iPad
- **Storage**: Varies based on number of cards
- **Camera**: Required for scanning

## 📂 Project Structure

```
Dearly/
├── Models/
│   └── Card.swift                    # SwiftData model
├── Services/
│   └── ImageStorageService.swift     # File-based image storage
├── Repository/
│   └── CardRepository.swift          # Data persistence layer
├── ViewModel/
│   └── CardsViewModel.swift          # Business logic
├── Views/
│   ├── Main/
│   │   ├── HomeView.swift           # Main grid view
│   │   └── DeveloperSettingsView.swift
│   ├── Card/
│   │   ├── CardItemView.swift       # Grid thumbnail
│   │   ├── CardDetailView.swift     # Full-screen viewer
│   │   ├── AnimatedCardView.swift   # 3D card component
│   │   ├── CardMetadataView.swift   # Edit metadata
│   │   └── ShareSheet.swift
│   ├── Scanner/
│   │   ├── ScanCardFlowView.swift   # Scanning workflow
│   │   ├── CardScannerView.swift    # Camera integration
│   │   └── CelebrationView.swift    # Success animation
│   └── Onboarding/
│       ├── OnboardingView.swift
│       └── OnboardingPage*.swift
└── DearlyApp.swift                   # App entry point
```

## 🔄 Recent Changes

### v1.1 - SwiftData Migration (Dec 2024)

- ✅ Migrated from UserDefaults to SwiftData for better scalability
- ✅ Implemented file-based image storage (no longer storing images in database)
- ✅ Added `ImageStorageService` for efficient file management
- ✅ Updated minimum iOS version to 17.6
- ✅ Improved performance with lazy image loading
- ✅ Added automatic legacy data cleanup

**Before:**

- Images stored as `Data` in UserDefaults (limited to ~4MB total)
- Performance degraded with each new card

**After:**

- Images stored as JPEG files in `Documents/CardImages/`
- Card metadata stored in SwiftData
- Scalable to thousands of cards
- Faster loading and better memory management

## 🎨 Design Philosophy

Dearly embraces a warm, nostalgic aesthetic with:

- **Cream and soft ivory backgrounds** reminiscent of aged paper
- **Rose and coral accents** for warmth and emotion
- **Frosted glass UI elements** for modern elegance
- **Smooth animations** that feel natural and delightful
- **3D interactions** that bring cards to life

## 🧪 Developer Tools

Access developer settings via the hammer icon in HomeView:

- **Performance Testing** - Load test with 10, 50, 100, or 500 cards
  - Real-time memory usage monitoring
  - Storage size tracking
  - Image file count statistics
  - App size tracking (bundle + user data)
  - Generation time metrics
  - Average storage per card
- Add dummy cards for testing
- Add 5 dummy cards at once
- Clear all cards and data
- Reset onboarding
- View card count

## 📝 Notes

### Image Storage

- Images compressed to 80% JPEG quality
- Stored in: `Documents/CardImages/{cardId}/{side}.jpg`
- Automatically cleaned up when cards are deleted
- File paths stored in SwiftData (lightweight)

### Performance

- Images loaded on-demand (not kept in memory)
- SwiftData handles efficient queries and updates
- Lazy loading in grid view
- Automatic change tracking

### Initial MVP Creation

- Took into account my local iphone iOS version, 16.3.1.
- Due to this had to refactor to implement FileManager library logic using new logic related to iOS 17 to avoid using core data (old) for swift data (new and simpler)
- Trying to clear storage on my phone 😭

## 📄 License

Private - All rights reserved

---

Made with ❤️ for preserving precious memories

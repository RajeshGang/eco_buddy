# EcoBuddy Watch App

Apple Watch companion app for EcoBuddy - your sustainability tracking companion on your wrist.

## Features

- **Leaderboard**: View your rank and points at a glance
- **Progress**: Track your sustainability score trends over time
- **Profile**: View your account information

## Requirements

- Xcode 14.0+
- watchOS 9.0+
- iOS 16.0+ (for companion app)
- Firebase account (shared with main app)
- Apple Developer account

## Quick Start

See `QUICK_START.md` for a 5-minute setup guide.

## Detailed Setup

See `XCODE_SETUP_GUIDE.md` for comprehensive step-by-step instructions.

## Project Structure

```
EcoBuddyWatch/
├── EcoBuddyWatchApp.swift      # App entry point
├── ContentView.swift            # Main navigation
├── Models/
│   └── LeaderboardEntry.swift  # Data models
├── Services/
│   ├── FirebaseManager.swift   # Firebase setup
│   ├── AuthManager.swift       # Authentication
│   ├── LeaderboardService.swift # Leaderboard data
│   └── ProgressService.swift   # Progress data
└── Views/
    ├── LeaderboardView.swift   # Leaderboard UI
    ├── ProgressView.swift       # Progress UI
    └── ProfileView.swift        # Profile UI
```

## Architecture

- **WatchKit Extension**: Main watch app code
- **WatchKit App**: Watch app bundle
- Uses Firebase Firestore for data synchronization with main app
- Shares authentication with companion iOS app

## Note

This is a companion app - scanning features are available in the main iOS app. The watch app focuses on quick access to your sustainability stats.

## Setup Checklist

Use `SETUP_CHECKLIST.md` to track your setup progress.

## License

MIT License - See LICENSE file


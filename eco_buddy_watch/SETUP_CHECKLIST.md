# Setup Checklist

Use this checklist to track your progress setting up the EcoBuddy Watch app.

## Pre-Setup
- [ ] Xcode 14.0+ installed
- [ ] Apple Developer account active
- [ ] Main iOS app running with Firebase
- [ ] GoogleService-Info.plist file available

## Step 1: Create Xcode Project
- [ ] Created new watchOS App project
- [ ] Named it "EcoBuddyWatch"
- [ ] Selected SwiftUI interface
- [ ] Selected Swift language
- [ ] Saved project

## Step 2: Add Files
- [ ] Created Models group
- [ ] Added LeaderboardEntry.swift
- [ ] Created Services group
- [ ] Added FirebaseManager.swift
- [ ] Added AuthManager.swift
- [ ] Added LeaderboardService.swift
- [ ] Added ProgressService.swift
- [ ] Created Views group
- [ ] Added LeaderboardView.swift
- [ ] Added ProgressView.swift
- [ ] Added ProfileView.swift
- [ ] Replaced EcoBuddyWatchApp.swift
- [ ] Replaced ContentView.swift
- [ ] Verified all files are in WatchKit Extension target

## Step 3: Install Firebase
- [ ] Opened Add Packages dialog
- [ ] Added firebase-ios-sdk package
- [ ] Selected FirebaseAuth product
- [ ] Selected FirebaseFirestore product
- [ ] Selected FirebaseCore product
- [ ] Added to WatchKit Extension target
- [ ] Verified package appears in Package Dependencies

## Step 4: Configure Firebase
- [ ] Copied GoogleService-Info.plist from main app
- [ ] Added to Xcode project
- [ ] Added to WatchKit Extension target ONLY
- [ ] Verified file appears in project navigator
- [ ] Verified target membership is correct

## Step 5: Update Bundle Identifiers
- [ ] Updated WatchKit Extension bundle ID
- [ ] Updated WatchKit App bundle ID
- [ ] Updated Info.plist WKCompanionAppBundleIdentifier
- [ ] Verified bundle IDs match pattern

## Step 6: Configure Signing
- [ ] Selected WatchKit Extension target
- [ ] Enabled automatic signing
- [ ] Selected developer team
- [ ] Selected WatchKit App target
- [ ] Enabled automatic signing
- [ ] Selected developer team
- [ ] Verified no signing errors

## Step 7: Code Updates
- [ ] Added `import FirebaseCore` to EcoBuddyWatchApp.swift
- [ ] Added `FirebaseApp.configure()` in init()
- [ ] Verified all imports are correct
- [ ] Fixed any compilation errors

## Step 8: Build & Test
- [ ] Selected WatchKit App scheme
- [ ] Selected watch simulator or device
- [ ] Built project (⌘B) - SUCCESS
- [ ] Ran project (⌘R) - SUCCESS
- [ ] App launches on watch
- [ ] Leaderboard view loads
- [ ] Progress view loads
- [ ] Profile view loads

## Verification Tests
- [ ] User can see their rank on leaderboard
- [ ] User can see their points
- [ ] Top users list displays
- [ ] Progress shows recent scores
- [ ] Profile shows user information
- [ ] Data syncs from main app

## Troubleshooting (if needed)
- [ ] Fixed "No such module" errors
- [ ] Fixed "Firebase not configured" errors
- [ ] Fixed bundle identifier conflicts
- [ ] Fixed signing issues
- [ ] Resolved all compilation errors

## Final Steps
- [ ] Tested on physical Apple Watch
- [ ] Verified all features work
- [ ] Ready to commit to Git
- [ ] Ready to push to separate repository

---

## Notes Section
Use this space to jot down any issues or customizations:

```
Date: ___________
Issues: 
- 

Solutions:
- 

Customizations:
- 
```


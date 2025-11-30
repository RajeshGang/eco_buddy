# Quick Start Guide

## Prerequisites Checklist
- [ ] Xcode 14.0+ installed
- [ ] Apple Developer account
- [ ] Main iOS app with Firebase configured
- [ ] GoogleService-Info.plist from main app

## 5-Minute Setup

### 1. Create Project (2 min)
```
Xcode → File → New → Project
→ watchOS → App
→ Name: EcoBuddyWatch
→ SwiftUI, Swift
```

### 2. Add Files (1 min)
```
Right-click project → Add Files
→ Select all Swift files from eco_buddy_watch/EcoBuddyWatch
→ ✅ Copy items
→ ✅ Add to WatchKit Extension target
```

### 3. Add Firebase (1 min)
```
File → Add Packages
→ https://github.com/firebase/firebase-ios-sdk
→ Select: FirebaseAuth, FirebaseFirestore, FirebaseCore
→ Add to WatchKit Extension target
```

### 4. Configure (1 min)
```
Add GoogleService-Info.plist to WatchKit Extension
Update bundle identifiers
Configure signing with your team
```

### 5. Build & Run
```
⌘B to build
⌘R to run
```

## Common Issues

**"No such module"** → Clean build (⌘⇧K), restart Xcode

**"Firebase not configured"** → Check GoogleService-Info.plist is in Extension target

**App won't run** → Ensure main iOS app is installed on paired iPhone

## Need Help?

See `XCODE_SETUP_GUIDE.md` for detailed step-by-step instructions.


# Detailed Xcode Setup Guide for EcoBuddy Watch App

## Step 3: Create Xcode Project

1. **Open Xcode** (version 14.0 or later)

2. **Create New Project:**
   - File → New → Project (or ⌘⇧N)
   - Select **watchOS** tab at the top
   - Choose **App** template
   - Click **Next**

3. **Configure Project:**
   - **Product Name:** `EcoBuddyWatch`
   - **Team:** Select your Apple Developer team
   - **Organization Identifier:** `com.example.ecoDemo` (or your identifier)
   - **Interface:** **SwiftUI**
   - **Language:** **Swift**
   - **Include Notification Scene:** Unchecked (optional)
   - Click **Next**

4. **Save Location:**
   - Choose where to save (can be in `eco_buddy_watch` folder)
   - **Create Git repository:** Unchecked (you'll push to separate repo)
   - Click **Create**

## Step 4: Add Files to Project

### Option A: Drag and Drop (Easiest)

1. In Finder, navigate to the `eco_buddy_watch/EcoBuddyWatch` folder
2. In Xcode, right-click on the project navigator (left sidebar)
3. Select **Add Files to "EcoBuddyWatch"...**
4. Navigate to and select these folders/files:
   - `Models/` folder
   - `Services/` folder  
   - `Views/` folder
   - Individual Swift files if not in folders
5. **Important Options:**
   - ✅ **Copy items if needed** (checked)
   - ✅ **Create groups** (not folder references)
   - ✅ **Add to targets:** Check **EcoBuddyWatch WatchKit Extension**
   - Click **Add**

### Option B: Manual Creation

1. **Create Groups in Xcode:**
   - Right-click project → New Group
   - Create: `Models`, `Services`, `Views`

2. **Add Files:**
   - Right-click each group → Add Files
   - Select corresponding Swift files
   - Ensure they're added to **WatchKit Extension** target

### Verify File Structure:
```
EcoBuddyWatch (Project)
├── EcoBuddyWatch WatchKit App
│   └── Assets.xcassets
├── EcoBuddyWatch WatchKit Extension
│   ├── EcoBuddyWatchApp.swift (replace existing)
│   ├── ContentView.swift
│   ├── Models/
│   │   └── LeaderboardEntry.swift
│   ├── Services/
│   │   ├── FirebaseManager.swift
│   │   ├── AuthManager.swift
│   │   ├── LeaderboardService.swift
│   │   └── ProgressService.swift
│   └── Views/
│       ├── LeaderboardView.swift
│       ├── ProgressView.swift
│       └── ProfileView.swift
```

## Step 5: Install Firebase Dependencies

### Using Swift Package Manager (Recommended)

1. **Add Package:**
   - In Xcode: File → Add Packages...
   - In the search bar, paste: `https://github.com/firebase/firebase-ios-sdk`
   - Click **Add Package**

2. **Select Products:**
   - Wait for package to resolve
   - In the "Add Package" dialog, select these products:
     - ✅ **FirebaseAuth**
     - ✅ **FirebaseFirestore**
     - ✅ **FirebaseCore**
   - **Add to Target:** Select **EcoBuddyWatch WatchKit Extension**
   - Click **Add Package**

3. **Verify Installation:**
   - Check Project Navigator → Package Dependencies
   - You should see `firebase-ios-sdk`

### Alternative: Using CocoaPods (if preferred)

1. Navigate to project directory in Terminal
2. Create `Podfile`:
   ```ruby
   platform :watchos, '9.0'
   
   target 'EcoBuddyWatch WatchKit Extension' do
     use_frameworks!
     pod 'Firebase/Auth'
     pod 'Firebase/Firestore'
   end
   ```
3. Run: `pod install`
4. Open `.xcworkspace` file (not `.xcodeproj`)

## Step 6: Configure Firebase

1. **Get GoogleService-Info.plist:**
   - From your main iOS app, copy `GoogleService-Info.plist`
   - Or download from Firebase Console:
     - Firebase Console → Project Settings → Your iOS App
     - Download `GoogleService-Info.plist`

2. **Add to Xcode:**
   - In Xcode, right-click **EcoBuddyWatch WatchKit Extension** group
   - Select **Add Files to "EcoBuddyWatch"...**
   - Select `GoogleService-Info.plist`
   - **Important:**
     - ✅ **Copy items if needed** (checked)
     - ✅ **Add to targets:** **EcoBuddyWatch WatchKit Extension** ONLY
     - ❌ Do NOT add to WatchKit App target
   - Click **Add**

3. **Verify:**
   - File should appear in WatchKit Extension group
   - Check Target Membership: Only WatchKit Extension should be checked

## Step 7: Update Bundle Identifiers

1. **Select Project in Navigator:**
   - Click on **EcoBuddyWatch** (blue icon at top)

2. **Select WatchKit Extension Target:**
   - In TARGETS, select **EcoBuddyWatch WatchKit Extension**
   - Go to **General** tab

3. **Update Bundle Identifier:**
   - **Bundle Identifier:** `com.example.ecoDemo.watchkitapp.watchkitextension`
     - Replace `com.example.ecoDemo` with your actual identifier

4. **Select WatchKit App Target:**
   - In TARGETS, select **EcoBuddyWatch WatchKit App**
   - **Bundle Identifier:** `com.example.ecoDemo.watchkitapp`

5. **Update Info.plist:**
   - Open `Info.plist` in WatchKit Extension
   - Find `WKCompanionAppBundleIdentifier`
   - Set value to your main iOS app's bundle ID: `com.example.ecoDemo`

## Step 8: Configure Signing & Capabilities

1. **Select WatchKit Extension Target:**
   - Go to **Signing & Capabilities** tab

2. **Configure Signing:**
   - ✅ **Automatically manage signing** (checked)
   - **Team:** Select your Apple Developer team
   - Xcode will automatically create provisioning profiles

3. **Add Capabilities (if needed):**
   - Click **+ Capability**
   - Add **Background Modes** (optional, for data refresh)
     - ✅ **Remote notifications** (if using push notifications)

4. **Repeat for WatchKit App Target:**
   - Select **EcoBuddyWatch WatchKit App** target
   - Configure signing with same team

## Step 9: Update Code for Firebase Initialization

1. **Open `EcoBuddyWatchApp.swift`**

2. **Add Firebase Import:**
   ```swift
   import FirebaseCore
   ```

3. **Update init():**
   ```swift
   init() {
       // Initialize Firebase
       FirebaseApp.configure()
   }
   ```

4. **Update `FirebaseManager.swift`:**
   - Remove the placeholder check
   - The `configure()` method can be simplified since Firebase is initialized in the app

## Step 10: Fix Import Statements

1. **Add Missing Imports:**
   - In `LeaderboardService.swift`: Already has `import FirebaseFirestore`
   - In `ProgressService.swift`: Already has `import FirebaseFirestore`
   - In `AuthManager.swift`: Already has `import FirebaseAuth`

2. **Verify All Files Compile:**
   - Press ⌘B to build
   - Fix any import errors

## Step 11: Build and Run

1. **Select Scheme:**
   - In Xcode toolbar, select **EcoBuddyWatch WatchKit App** scheme
   - Select destination:
     - **Apple Watch Series 9 (45mm)** (Simulator)
     - Or connect a physical Apple Watch

2. **Build:**
   - Press ⌘B or Product → Build
   - Fix any compilation errors

3. **Run:**
   - Press ⌘R or Product → Run
   - App will install on watch simulator/device

## Troubleshooting

### Error: "Firebase not configured"
- Ensure `GoogleService-Info.plist` is in WatchKit Extension target
- Check that `FirebaseApp.configure()` is called in `EcoBuddyWatchApp.swift`

### Error: "No such module 'FirebaseAuth'"
- Verify package is added to correct target (WatchKit Extension)
- Clean build folder: Product → Clean Build Folder (⌘⇧K)
- Restart Xcode

### Error: "Bundle identifier conflicts"
- Ensure WatchKit Extension and WatchKit App have different bundle IDs
- Check that companion app bundle ID matches your iOS app

### App doesn't appear on watch
- Ensure main iOS app is installed on paired iPhone
- Check that bundle identifiers match
- Verify watch is paired and connected

### Authentication not working
- Ensure user is signed in on main iOS app first
- Check Firebase project is shared between iOS and watchOS apps
- Verify Firestore security rules allow read access

## Next Steps After Setup

1. **Test Features:**
   - Launch app on watch
   - Verify leaderboard loads
   - Check progress view shows data
   - Confirm profile displays user info

2. **Customize:**
   - Adjust UI for watch screen sizes
   - Add complications (optional)
   - Implement watch-specific gestures

3. **Deploy:**
   - Archive for App Store
   - Test on physical device
   - Submit to App Store Connect

## File Checklist

After setup, verify you have:
- ✅ All Swift files in correct groups
- ✅ Firebase packages installed
- ✅ GoogleService-Info.plist added
- ✅ Bundle identifiers configured
- ✅ Signing configured
- ✅ Project builds without errors


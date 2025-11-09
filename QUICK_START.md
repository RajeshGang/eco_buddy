# Quick Start Guide - EcoBuddy Development

## 🚀 Getting Started in 5 Minutes

### Prerequisites
- Flutter SDK (3.8.0+)
- Xcode (for iOS) or Android Studio (for Android)
- Firebase project configured
- Device or simulator

### 1. Clone & Install
```bash
cd /Users/rahulrajesh/coding/eco_buddy
flutter pub get
```

### 2. Firebase Setup
Firebase is already configured! The app uses:
- `firebase_options.dart` - Auto-generated config
- `.firebaserc` - Project settings

### 3. Run the App
```bash
# iOS Simulator
flutter run -d "iPhone 15 Pro"

# Android Emulator
flutter run -d emulator-5554

# Physical Device
flutter run
```

## 📱 Testing the Features

### Test Barcode Scanner
1. Navigate to "Scan" tab
2. Point camera at any barcode
3. If product not in catalog, you'll see a message
4. Add test products to Firebase first (see below)

### Test Receipt Scanner
1. Navigate to "Receipts" tab
2. Take photo of a receipt or select from gallery
3. Wait for OCR processing
4. View parsed items and scores

### Test Demo Mode
1. Navigate to "Demo" tab
2. Tap any product to test points
3. View recommendations for alternatives
4. Check leaderboard to see points

## 🔥 Firebase Setup

### Required Collections

#### 1. Catalog (for barcode scanning)
```javascript
// Path: /catalog/items/byUpc/{upc}
{
  "name": "Organic Avocados",
  "brand": "Whole Foods",
  "category": "Food & Grocery",
  "baseScore": 85
}
```

**Add test products:**
```bash
# Use Firebase Console or add via code
```

#### 2. Leaderboard (auto-created on first scan)
```javascript
// Path: /leaderboard/{uid}
{
  "displayName": "User Name",
  "totalPoints": 0,
  "lastUpdated": timestamp
}
```

#### 3. Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Catalog - read only
    match /catalog/{document=**} {
      allow read: if request.auth != null;
    }
    
    // Leaderboard - read all, write own
    match /leaderboard/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid;
    }
    
    // User purchases
    match /users/{uid}/purchases/{purchase} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

## 🤖 AI Recommendations Setup (Optional)

### Using Real AI (Google Gemini)
1. Get free API key: https://aistudio.google.com/app/apikey
2. Open `lib/features/catalog/ai_recommendation_service.dart`
3. Replace line 29:
```dart
static const String _apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### Using Mock Recommendations
- No setup needed!
- Smart category-based recommendations work automatically
- Perfect for development and testing

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase config
└── features/
    ├── auth/                          # Authentication
    │   ├── auth_gate.dart
    │   ├── sign_in_page.dart
    │   └── profile_screen.dart
    ├── scan/                          # Scanning features
    │   ├── barcode_scanner_screen_mobile.dart
    │   ├── receipt_ocr_screen_mobile.dart
    │   ├── scan_result_screen.dart          # NEW
    │   ├── receipt_results_screen.dart      # NEW
    │   └── receipt_parser.dart              # NEW
    ├── catalog/                       # Scoring & recommendations
    │   ├── scoring_service.dart
    │   ├── ai_recommendation_service.dart
    │   ├── leaderboard_service.dart
    │   ├── upc_lookup_service.dart
    │   ├── test_points_screen.dart
    │   └── product_detail_screen.dart
    ├── purchases/                     # Purchase models
    │   ├── purchase_model.dart
    │   └── purchase_repo.dart
    └── stats/                         # Progress tracking
        └── trends_screen.dart
```

## 🧪 Testing Checklist

### Barcode Scanner
- [ ] Camera opens correctly
- [ ] Barcode detection works
- [ ] Product lookup succeeds
- [ ] Score calculation works
- [ ] Points awarded to leaderboard
- [ ] AI recommendations appear
- [ ] Navigation back works

### Receipt Scanner
- [ ] Camera/gallery picker works
- [ ] OCR extracts text
- [ ] Items parsed correctly
- [ ] Scores calculated for items
- [ ] Overall score shown
- [ ] Points awarded
- [ ] Item detail view works

### Points System
- [ ] Points added to leaderboard
- [ ] Bonus points for high scores
- [ ] Leaderboard updates in real-time
- [ ] User rank calculated correctly

### AI Recommendations
- [ ] Recommendations load
- [ ] Category-specific suggestions
- [ ] Score improvements shown
- [ ] Reasoning displayed

## 🐛 Common Issues & Solutions

### Issue: "Firebase not initialized"
**Solution**: Ensure `Firebase.initializeApp()` completes in `main.dart`

### Issue: "Product not found"
**Solution**: Add test products to Firestore `/catalog/items/byUpc/`

### Issue: "Camera permission denied"
**Solution**: 
- iOS: Check `Info.plist` for camera permissions
- Android: Check `AndroidManifest.xml`

### Issue: "OCR not working"
**Solution**: Ensure `google_mlkit_text_recognition` is properly installed

### Issue: "No AI recommendations"
**Solution**: Check internet connection; fallback recommendations should still work

### Issue: "Points not updating"
**Solution**: Check Firestore rules allow write access to `/leaderboard/{uid}`

## 🔧 Development Commands

```bash
# Run app
flutter run

# Run with specific device
flutter run -d <device-id>

# List devices
flutter devices

# Clean build
flutter clean && flutter pub get

# Build release
flutter build ios --release
flutter build apk --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## 📝 Adding Test Data

### Add Sample Products to Firebase
Use Firebase Console or this code snippet:

```dart
// Add to Firestore
await FirebaseFirestore.instance
  .collection('catalog')
  .doc('items')
  .collection('byUpc')
  .doc('012345678901')
  .set({
    'name': 'Organic Bananas',
    'brand': 'Local Farm',
    'category': 'Food & Grocery',
    'baseScore': 88.0,
  });
```

### Common UPC Codes for Testing
- `012345678901` - Test product 1
- `098765432109` - Test product 2
- `111111111111` - Test product 3

## 🎯 Next Steps

1. **Add Real Products**: Populate Firebase catalog with actual products
2. **Enable AI**: Add Gemini API key for real recommendations
3. **Customize Scoring**: Adjust scoring logic in `scoring_service.dart`
4. **Add Analytics**: Integrate Firebase Analytics
5. **Test on Device**: Test camera features on physical device
6. **Deploy**: Build and deploy to App Store / Play Store

## 📚 Documentation

- **Integration Summary**: `INTEGRATION_SUMMARY.md`
- **User Guide**: `USER_GUIDE.md`
- **Technical Architecture**: `TECHNICAL_ARCHITECTURE.md`
- **This Guide**: `QUICK_START.md`

## 💡 Pro Tips

1. **Use Demo Tab**: Great for testing without scanning
2. **Check Console**: Watch debug prints for flow understanding
3. **Test Offline**: Verify fallback recommendations work
4. **Mock Data**: Use receipt parser with sample text
5. **Hot Reload**: Use `r` in terminal for quick UI updates

## 🆘 Need Help?

1. Check the documentation files
2. Review code comments
3. Test with Demo tab first
4. Check Firebase Console for data
5. Review error messages in console

---

**Happy Coding! 🎉**

Start with the Demo tab, then test barcode scanning, then receipt scanning!

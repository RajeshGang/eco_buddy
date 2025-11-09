# EcoBuddy Technical Architecture

## System Overview

EcoBuddy is a Flutter-based mobile application that helps users make sustainable purchasing decisions through barcode scanning, receipt analysis, and AI-powered recommendations.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter App                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Barcode    │  │   Receipt    │  │    Demo      │      │
│  │   Scanner    │  │     OCR      │  │    Mode      │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            ▼                                 │
│         ┌──────────────────────────────────┐                │
│         │     Scan Result Screen           │                │
│         │  - Score Display                 │                │
│         │  - AI Recommendations            │                │
│         │  - Points Award                  │                │
│         └──────────────────────────────────┘                │
│                            │                                 │
│         ┌──────────────────┼──────────────────┐             │
│         ▼                  ▼                  ▼             │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Scoring   │  │      AI      │  │ Leaderboard  │      │
│  │   Service   │  │ Recommend.   │  │   Service    │      │
│  └─────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                     Firebase Backend                         │
├─────────────────────────────────────────────────────────────┤
│  • Firestore (Database)                                      │
│  • Authentication                                             │
│  • Storage (Receipt Images)                                  │
└─────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│              External APIs (Optional)                        │
├─────────────────────────────────────────────────────────────┤
│  • Google Gemini API (AI Recommendations)                   │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Scanning Layer

#### Barcode Scanner (`barcode_scanner_screen_mobile.dart`)
- **Technology**: `mobile_scanner` package
- **Flow**:
  1. Captures barcode using device camera
  2. Extracts UPC/EAN code
  3. Queries Firebase catalog
  4. Calculates sustainability score
  5. Awards points
  6. Displays results with AI recommendations

#### Receipt OCR (`receipt_ocr_screen_mobile.dart`)
- **Technology**: `google_mlkit_text_recognition`
- **Flow**:
  1. Captures receipt image (camera or gallery)
  2. Performs OCR text extraction
  3. Parses items using `ReceiptParser`
  4. Calculates scores for each item
  5. Awards points based on overall score
  6. Displays results with item breakdown

#### Receipt Parser (`receipt_parser.dart`)
- **Purpose**: Extract structured data from OCR text
- **Capabilities**:
  - Item name extraction
  - Quantity detection
  - Price parsing
  - Automatic categorization
  - Score estimation based on keywords

### 2. Scoring System

#### Scoring Service (`scoring_service.dart`)
```dart
Future<double> scoreItem({
  required String category,
  required double baseScore,
  Map<String, dynamic>? attributes
})
```
- Base score from catalog or estimation
- Attribute modifiers (reusable, local, etc.)
- Category-specific adjustments
- Returns score 0-100

#### Score Calculation Logic:
```
Final Score = Base Score + Attribute Bonuses
- Organic: +20
- Local: +15
- Reusable: +20
- Plastic: -20
- Disposable: -15
```

### 3. Points & Leaderboard

#### Leaderboard Service (`leaderboard_service.dart`)
- **Client-side implementation** (no Cloud Functions needed)
- **Features**:
  - Transaction-based point updates
  - Bonus point calculation
  - Real-time leaderboard updates
  - User rank calculation

#### Point Award Logic:
```dart
Base Points = Sustainability Score
Bonus Points:
  - Score >= 90: +20 points
  - Score >= 75: +10 points
  - Score >= 60: +5 points
Total Points = Base + Bonus
```

### 4. AI Recommendations

#### AI Recommendation Service (`ai_recommendation_service.dart`)
- **Primary**: Google Gemini API (optional)
- **Fallback**: Smart category-based recommendations
- **Features**:
  - Context-aware suggestions
  - Score estimation for alternatives
  - Detailed reasoning
  - Category-specific logic

#### Recommendation Categories:
1. **Food & Grocery**: Organic, local, bulk
2. **Personal Care**: Natural, refillable, zero-waste
3. **Household**: Plant-based, concentrated, DIY
4. **General**: Eco-friendly, durable, second-hand

### 5. Data Models

#### Purchase Model (`purchase_model.dart`)
```dart
class PurchaseItem {
  String? upc;
  String description;
  int qty;
  double unitPrice;
  String? category;
  double? score;
  String? scoreVersion;
}

class Purchase {
  String id;
  String merchant;
  DateTime purchaseDate;
  double subtotal;
  List<PurchaseItem> items;
  String? receiptImagePath;
  double? purchaseScore;
}
```

#### Catalog Item (`upc_lookup_service.dart`)
```dart
class CatalogItem {
  String upc;
  String name;
  String? brand;
  String category;
  double baseScore;
}
```

## Firebase Structure

### Firestore Collections

```
/catalog/items/byUpc/{upc}
  - name: string
  - brand: string
  - category: string
  - baseScore: number

/leaderboard/{uid}
  - displayName: string
  - totalPoints: number
  - lastUpdated: timestamp

/users/{uid}/purchases/{purchaseId}
  - merchant: string
  - purchaseDate: timestamp
  - subtotal: number
  - items: array
  - receiptImagePath: string
  - purchaseScore: number

/score_versions/{versionId}
  - version: string
  - createdAt: timestamp
  - algorithm: string
```

## UI/UX Flow

### Barcode Scan Flow
```
Scan Tab → Camera View → Barcode Detected
  → Product Lookup → Score Calculation
  → Points Award → Result Screen
  → AI Recommendations → Done
```

### Receipt Scan Flow
```
Receipts Tab → Photo Capture → OCR Processing
  → Item Parsing → Score Calculation (per item)
  → Overall Score → Points Award
  → Results Screen → Item Details (tap)
  → AI Recommendations → Done
```

## State Management

- **Local State**: `StatefulWidget` with `setState()`
- **Async Operations**: `Future` and `async/await`
- **Streams**: Firebase real-time listeners
- **Loading States**: Boolean flags with UI indicators

## Error Handling

### Strategies:
1. **Try-Catch Blocks**: All async operations
2. **Null Safety**: Dart null-safety enabled
3. **User Feedback**: SnackBar notifications
4. **Fallbacks**: Smart defaults when services fail
5. **Retry Logic**: User-initiated retries

### Common Errors:
- Product not found → Friendly message
- OCR failure → Retry with tips
- Network issues → Offline mode suggestions
- API limits → Fallback recommendations

## Performance Optimizations

### Image Processing:
- Image quality: 85% (balance quality/size)
- Lazy loading for lists
- Cached network images

### Database:
- Indexed queries on Firestore
- Batch operations where possible
- Pagination for large lists

### UI:
- Async loading indicators
- Optimistic UI updates
- Debounced search inputs

## Security

### Firebase Rules:
```javascript
// Leaderboard - read all, write own
match /leaderboard/{uid} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == uid;
}

// Purchases - read/write own only
match /users/{uid}/purchases/{purchase} {
  allow read, write: if request.auth.uid == uid;
}

// Catalog - read only
match /catalog/{document=**} {
  allow read: if request.auth != null;
}
```

### API Keys:
- Gemini API key in code (should be moved to env)
- Firebase config in `firebase_options.dart`

## Testing Strategy

### Unit Tests:
- Receipt parser logic
- Score calculation
- Point award calculation

### Integration Tests:
- Firebase operations
- OCR processing
- API calls

### Manual Testing:
- Camera functionality
- UI flows
- Error scenarios

## Deployment

### iOS:
```bash
flutter build ios --release
# Open in Xcode for signing and deployment
```

### Android:
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## Dependencies

### Core:
- `flutter`: ^3.8.0
- `firebase_core`: ^4.2.1
- `firebase_auth`: ^6.1.2
- `cloud_firestore`: ^6.1.0

### Scanning:
- `mobile_scanner`: ^7.1.2
- `google_mlkit_text_recognition`: ^0.15.0
- `image_picker`: ^1.1.2
- `camera`: ^0.11.2+1

### Networking:
- `http`: ^1.5.0

### UI:
- `fl_chart`: ^0.69.0
- `intl`: ^0.19.0

## Future Enhancements

### Technical:
- [ ] Move API keys to environment variables
- [ ] Implement caching layer
- [ ] Add offline mode
- [ ] Optimize image compression
- [ ] Implement analytics
- [ ] Add crash reporting

### Features:
- [ ] Purchase history persistence
- [ ] Trend analysis
- [ ] Product comparison
- [ ] Social features
- [ ] Gamification
- [ ] Push notifications

## Monitoring & Analytics

### Recommended Tools:
- Firebase Analytics
- Firebase Crashlytics
- Firebase Performance Monitoring
- Custom event tracking

### Key Metrics:
- Scan success rate
- OCR accuracy
- User engagement
- Point distribution
- Recommendation click-through

## Development Guidelines

### Code Style:
- Follow Dart style guide
- Use meaningful variable names
- Comment complex logic
- Keep functions small and focused

### Git Workflow:
- Feature branches
- Descriptive commit messages
- Pull request reviews
- Semantic versioning

### Documentation:
- Code comments for complex logic
- README for setup instructions
- API documentation
- User guides

---

**Last Updated**: November 2024
**Version**: 1.0.0
**Maintainer**: Development Team

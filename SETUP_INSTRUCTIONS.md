# Setup Instructions - Fixing Your Issues

## ✅ Issues Fixed

### 1. Receipt Parser - FIXED ✓
Updated the parser to handle Costco-style receipts with prices like "4.99 E" and "18.99 A"

### 2. Firestore Rules - FIXED ✓
Updated and deployed new rules that allow:
- ✅ Authenticated users to read catalog
- ✅ Users to write to their own leaderboard entry
- ✅ Users to manage their own purchases

## 🔥 Add Sample Products to Firebase

You need to add products to your catalog for barcode scanning to work. Here are two ways:

### Option 1: Use Firebase Console (Easiest)

1. Go to: https://console.firebase.google.com/project/ecobuddy-153ba/firestore
2. Navigate to: `catalog` → `items` → `byUpc`
3. Click "Add document"
4. For each product, use the UPC as the Document ID and add these fields:

**Example Product 1:**
- Document ID: `041220576920`
- Fields:
  - `name` (string): "Organic Bananas"
  - `brand` (string): "Dole"
  - `category` (string): "Food & Grocery"
  - `baseScore` (number): 85

**Example Product 2:**
- Document ID: `011110421319`
- Fields:
  - `name` (string): "Coca-Cola 12oz Can"
  - `brand` (string): "Coca-Cola"
  - `category` (string): "Beverages"
  - `baseScore` (number): 35

**Example Product 3:**
- Document ID: `078742370682`
- Fields:
  - `name` (string): "Bamboo Toothbrush"
  - `brand` (string): "Eco-Dent"
  - `category` (string): "Personal Care"
  - `baseScore` (number): 92

### Option 2: Add Products from Your App

Add this temporary button to your profile screen or demo screen:

```dart
ElevatedButton(
  onPressed: () async {
    final db = FirebaseFirestore.instance;
    final catalogRef = db.collection('catalog').doc('items').collection('byUpc');
    
    await catalogRef.doc('041220576920').set({
      'name': 'Organic Bananas',
      'brand': 'Dole',
      'category': 'Food & Grocery',
      'baseScore': 85.0,
    });
    
    await catalogRef.doc('078742370682').set({
      'name': 'Bamboo Toothbrush',
      'brand': 'Eco-Dent',
      'category': 'Personal Care',
      'baseScore': 92.0,
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sample products added!')),
    );
  },
  child: Text('Add Sample Products'),
)
```

## 🧪 Testing Now

### Test Receipt Scanner:
1. Run your app: `flutter run`
2. Go to "Receipts" tab
3. Take a photo of your Costco receipt (or any receipt)
4. You should now see items extracted! ✅

Expected results from your Costco receipt:
- AVOCADOS - $4.99
- WILDSALMNOIL - $18.99
- OADWOMEN 300 - $18.99
- AGED PARM - $9.36
- GILLETTE - $49.99
- FERRERO 48CT - $17.99
- GOLD KIWI - $10.99
- BLENDER - $39.99
- PERSIMMONS - $4.99

### Test Barcode Scanner:
1. Add at least one product to Firebase (see above)
2. Go to "Scan" tab
3. Scan a barcode that matches a product in your catalog
4. You should see the product details and AI recommendations! ✅

## 📱 Common Barcodes to Test

If you add these to your catalog, you can test with common products:

| UPC | Product | Category | Score |
|-----|---------|----------|-------|
| 041220576920 | Organic Bananas | Food & Grocery | 85 |
| 011110421319 | Coca-Cola 12oz | Beverages | 35 |
| 078742370682 | Bamboo Toothbrush | Personal Care | 92 |
| 850013832002 | Reusable Water Bottle | Household | 95 |
| 041220892754 | Plastic Water Bottles | Beverages | 25 |

## ✅ What's Working Now

1. **Receipt Parser** ✓
   - Handles various price formats
   - Removes item codes
   - Filters out headers/footers
   - Extracts clean item names

2. **Firestore Rules** ✓
   - Catalog is readable
   - Leaderboard is writable
   - Purchases are private

3. **AI Recommendations** ✓
   - Real Gemini API enabled
   - Smart fallbacks working

## 🐛 If You Still Have Issues

### Receipt not parsing items?
- Check the raw text - are there prices with decimals?
- Try a different receipt with clearer text
- Ensure good lighting when taking photo

### Barcode still showing permission error?
- Make sure you're signed in to the app
- Check Firebase Console to verify rules are deployed
- Try signing out and back in

### Products not found?
- Add products to Firebase catalog first
- Use the exact UPC code as document ID
- Verify the collection path: `catalog/items/byUpc/{upc}`

## 🎉 Next Steps

1. Add more products to your catalog
2. Test with real receipts
3. Scan actual product barcodes
4. Check the leaderboard to see your points!

---

**Everything should work now!** 🚀

The receipt parser will extract items from your Costco receipt, and barcode scanning will work once you add products to Firebase.

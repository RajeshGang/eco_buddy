import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Run this script to add sample products to your catalog
/// Usage: dart run add_sample_products.dart
Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final db = FirebaseFirestore.instance;
  final catalogRef = db.collection('catalog').doc('items').collection('byUpc');

  // Sample products with common UPC codes
  final sampleProducts = [
    {
      'upc': '041220576920',
      'name': 'Organic Bananas',
      'brand': 'Dole',
      'category': 'Food & Grocery',
      'baseScore': 85.0,
    },
    {
      'upc': '011110421319',
      'name': 'Coca-Cola 12oz Can',
      'brand': 'Coca-Cola',
      'category': 'Beverages',
      'baseScore': 35.0,
    },
    {
      'upc': '028400064958',
      'name': 'Cheerios Cereal',
      'brand': 'General Mills',
      'category': 'Food & Grocery',
      'baseScore': 65.0,
    },
    {
      'upc': '052100031576',
      'name': 'Tide Laundry Detergent',
      'brand': 'Tide',
      'category': 'Household',
      'baseScore': 45.0,
    },
    {
      'upc': '037000127376',
      'name': 'Crest Toothpaste',
      'brand': 'Crest',
      'category': 'Personal Care',
      'baseScore': 55.0,
    },
    {
      'upc': '012000161551',
      'name': 'Pepsi 2 Liter',
      'brand': 'Pepsi',
      'category': 'Beverages',
      'baseScore': 30.0,
    },
    {
      'upc': '041303001639',
      'name': 'Organic Avocados',
      'brand': 'Whole Foods',
      'category': 'Food & Grocery',
      'baseScore': 90.0,
    },
    {
      'upc': '078742370682',
      'name': 'Bamboo Toothbrush',
      'brand': 'Eco-Dent',
      'category': 'Personal Care',
      'baseScore': 92.0,
    },
    {
      'upc': '850013832002',
      'name': 'Reusable Water Bottle',
      'brand': 'Hydro Flask',
      'category': 'Household',
      'baseScore': 95.0,
    },
    {
      'upc': '041220892754',
      'name': 'Plastic Water Bottles 24-pack',
      'brand': 'Nestle',
      'category': 'Beverages',
      'baseScore': 25.0,
    },
  ];

  print('Adding ${sampleProducts.length} sample products to catalog...\n');

  for (var product in sampleProducts) {
    try {
      await catalogRef.doc(product['upc'] as String).set(product);
      print('✅ Added: ${product['name']} (UPC: ${product['upc']})');
    } catch (e) {
      print('❌ Error adding ${product['name']}: $e');
    }
  }

  print('\n🎉 Done! You can now scan these barcodes in the app.');
  print('\nTo test, try scanning any of these UPC codes:');
  for (var product in sampleProducts) {
    print('  ${product['upc']} - ${product['name']}');
  }
}

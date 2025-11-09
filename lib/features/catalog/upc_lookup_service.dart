import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogItem {
  final String upc; final String name; final String? brand; final String category; final double baseScore;
  CatalogItem({required this.upc, required this.name, this.brand, required this.category, required this.baseScore});
}

class UpcLookupService {
  UpcLookupService._();
  static final instance = UpcLookupService._();
  final _db = FirebaseFirestore.instance;
  Future<CatalogItem?> lookup(String upc) async {
    final snap = await _db.collection('catalog').doc('items').collection('byUpc').doc(upc).get();
    if (!snap.exists) return null;
    final d = snap.data()!;
    return CatalogItem(upc: upc, name: d['name'], brand: d['brand'], category: d['category'], baseScore: (d['baseScore'] as num).toDouble());
  }
}

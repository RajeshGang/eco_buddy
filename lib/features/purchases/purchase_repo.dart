import 'package:cloud_firestore/cloud_firestore.dart';
import 'purchase_model.dart';

class PurchaseRepo {
  final _db = FirebaseFirestore.instance;
  Future<void> savePurchase(String uid, Purchase p) async {
    await _db.collection('users').doc(uid).collection('purchases').doc(p.id).set(p.toMap());
  }
}

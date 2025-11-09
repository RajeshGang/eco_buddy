import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'receipt_parser.dart';

/// Service to manage receipt history in Firestore
class ReceiptHistoryService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Save a receipt to history
  Future<String> saveReceipt({
    required List<ReceiptItem> items,
    required String rawText,
    required double overallScore,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final receiptData = {
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'overallScore': overallScore,
      'itemCount': items.length,
      'items': items.map((item) => {
        'description': item.description,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
      }).toList(),
      'rawText': rawText,
    };

    final docRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('receipts')
        .add(receiptData);

    return docRef.id;
  }

  /// Get all receipts for the current user
  Stream<List<ReceiptHistory>> getReceiptHistory() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('receipts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ReceiptHistory(
          id: doc.id,
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          overallScore: (data['overallScore'] as num?)?.toDouble() ?? 0.0,
          itemCount: data['itemCount'] as int? ?? 0,
          items: (data['items'] as List<dynamic>?)?.map((item) {
            return ReceiptItem(
              description: item['description'] as String? ?? '',
              quantity: item['quantity'] as int? ?? 1,
              unitPrice: (item['unitPrice'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList() ?? [],
          rawText: data['rawText'] as String? ?? '',
        );
      }).toList();
    });
  }

  /// Delete a receipt
  Future<void> deleteReceipt(String receiptId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('receipts')
        .doc(receiptId)
        .delete();
  }
}

/// Model for receipt history
class ReceiptHistory {
  final String id;
  final DateTime timestamp;
  final double overallScore;
  final int itemCount;
  final List<ReceiptItem> items;
  final String rawText;

  ReceiptHistory({
    required this.id,
    required this.timestamp,
    required this.overallScore,
    required this.itemCount,
    required this.items,
    required this.rawText,
  });
}

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoringService {
  final _db = FirebaseFirestore.instance;
  Future<double> scoreItem({required String category, required double baseScore, Map<String, dynamic>? attributes}) async {
    final ver = await _db.collection('score_versions').orderBy('createdAt', descending: true).limit(1).get();
    double s = baseScore;
    final a = attributes ?? {};
    if (a['reusable'] == true) s += 5;
    if (a['local'] == true) s += 3;
    return max(0, min(100, s));
  }
}

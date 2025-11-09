import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int totalPoints;
  final DateTime lastUpdated;

  LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.totalPoints,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'totalPoints': totalPoints,
    'lastUpdated': lastUpdated,
  };

  factory LeaderboardEntry.fromMap(String uid, Map<String, dynamic> map) {
    return LeaderboardEntry(
      uid: uid,
      displayName: map['displayName'] ?? 'Anonymous',
      totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class LeaderboardService {
  final _db = FirebaseFirestore.instance;

  /// Update user's leaderboard entry after a purchase
  Future<void> updateUserScore(String uid, int pointsToAdd) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final leaderboardRef = _db.collection('leaderboard').doc(uid);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(leaderboardRef);
      
      int currentPoints = 0;
      if (snapshot.exists) {
        currentPoints = (snapshot.data()?['totalPoints'] as num?)?.toInt() ?? 0;
      }
      
      transaction.set(leaderboardRef, {
        'displayName': user.displayName ?? user.email ?? 'Anonymous',
        'totalPoints': currentPoints + pointsToAdd,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  /// Get top N users on leaderboard
  Stream<List<LeaderboardEntry>> getTopUsers({int limit = 50}) {
    return _db
        .collection('leaderboard')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaderboardEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Get current user's rank
  Future<int?> getUserRank(String uid) async {
    final userDoc = await _db.collection('leaderboard').doc(uid).get();
    if (!userDoc.exists) return null;

    final userPoints = (userDoc.data()?['totalPoints'] as num?)?.toInt() ?? 0;

    final higherCount = await _db
        .collection('leaderboard')
        .where('totalPoints', isGreaterThan: userPoints)
        .count()
        .get();

    return (higherCount.count ?? 0) + 1;
  }

  /// Get user's current points
  Future<int> getUserPoints(String uid) async {
    final doc = await _db.collection('leaderboard').doc(uid).get();
    if (!doc.exists) return 0;
    return (doc.data()?['totalPoints'] as num?)?.toInt() ?? 0;
  }
}
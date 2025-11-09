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

  /// Update user's leaderboard entry - CLIENT SIDE (no Cloud Functions needed!)
  Future<void> updateUserScore(int pointsToAdd) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final leaderboardRef = _db.collection('leaderboard').doc(user.uid);
    
    try {
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
      
      print('✅ Added $pointsToAdd points to leaderboard');
    } catch (e) {
      print('❌ Error updating leaderboard: $e');
    }
  }

  /// Manually calculate and award points for a purchase score
  Future<void> awardPointsForPurchase(double purchaseScore) async {
    if (purchaseScore <= 0) return;
    
    // Convert score to points (1 point per score point)
    final points = purchaseScore.round();
    
    // Award bonus points for high scores
    int bonusPoints = 0;
    if (purchaseScore >= 90) {
      bonusPoints = 20; // Excellent!
    } else if (purchaseScore >= 75) {
      bonusPoints = 10; // Great!
    } else if (purchaseScore >= 60) {
      bonusPoints = 5; // Good!
    }
    
    await updateUserScore(points + bonusPoints);
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
    try {
      final userDoc = await _db.collection('leaderboard').doc(uid).get();
      if (!userDoc.exists) return null;

      final userPoints = (userDoc.data()?['totalPoints'] as num?)?.toInt() ?? 0;

      final higherCount = await _db
          .collection('leaderboard')
          .where('totalPoints', isGreaterThan: userPoints)
          .count()
          .get();

      return (higherCount.count ?? 0) + 1;
    } catch (e) {
      print('Error getting user rank: $e');
      return null;
    }
  }

  /// Get user's current points
  Future<int> getUserPoints(String uid) async {
    try {
      final doc = await _db.collection('leaderboard').doc(uid).get();
      if (!doc.exists) return 0;
      return (doc.data()?['totalPoints'] as num?)?.toInt() ?? 0;
    } catch (e) {
      print('Error getting user points: $e');
      return 0;
    }
  }
  
  /// Initialize user on leaderboard if they don't exist
  Future<void> initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final doc = await _db.collection('leaderboard').doc(user.uid).get();
    if (!doc.exists) {
      await _db.collection('leaderboard').doc(user.uid).set({
        'displayName': user.displayName ?? user.email ?? 'Anonymous',
        'totalPoints': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }
}
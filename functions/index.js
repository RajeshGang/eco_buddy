const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onPurchaseWrite = functions.firestore
  .document('users/{uid}/purchases/{purchaseId}')
  .onWrite(async (change, ctx) => {
    const after = change.after.exists ? change.after.data() : null;
    if (!after) return;
    
    const items = after.items || [];
    let sum = 0, w = 0;
    
    // Calculate weighted purchase score
    for (const it of items) {
      const s = Number(it.score ?? 0);
      const qty = Number(it.qty ?? 1);
      const price = Number(it.unitPrice ?? 1);
      const weight = isFinite(price) && price > 0 ? qty * price : qty;
      sum += s * weight; 
      w += weight;
    }
    
    const purchaseScore = w > 0 ? Math.round((sum / w) * 10) / 10 : null;
    
    // Update the purchase document with calculated score
    await change.after.ref.update({ purchaseScore });
    
    // Update monthly aggregates
    const d = after.purchaseDate?.toDate ? after.purchaseDate.toDate() : new Date();
    const key = `${d.getFullYear()}${String(d.getMonth()+1).padStart(2,'0')}`;
    const aggRef = change.after.ref.parent.parent
      .collection('aggregates')
      .doc('month')
      .collection('all')
      .doc(key);
    
    await admin.firestore().runTransaction(async (tx) => {
      const snap = await tx.get(aggRef);
      const prev = snap.exists ? snap.data() : { totalScore: 0, itemCount: 0 };
      const addCount = items.reduce((a,b)=> a + Number(b.qty||1), 0);
      tx.set(aggRef, { 
        totalScore: (prev.totalScore||0) + (purchaseScore||0), 
        itemCount: (prev.itemCount||0) + addCount 
      }, { merge: true });
    });
    
    // Update leaderboard - add points based on purchase score
    if (purchaseScore && purchaseScore > 0) {
      const points = Math.round(purchaseScore);
      const leaderboardRef = admin.firestore()
        .collection('leaderboard')
        .doc(ctx.params.uid);
      
      await admin.firestore().runTransaction(async (tx) => {
        const leaderboardSnap = await tx.get(leaderboardRef);
        let currentPoints = 0;
        let displayName = 'Anonymous';
        
        if (leaderboardSnap.exists) {
          const data = leaderboardSnap.data();
          currentPoints = data.totalPoints || 0;
          displayName = data.displayName || 'Anonymous';
        }
        
        // Try to get user display name from Firebase Auth
        try {
          const userRecord = await admin.auth().getUser(ctx.params.uid);
          displayName = userRecord.displayName || userRecord.email || 'Anonymous';
        } catch (err) {
          console.log('Could not fetch user name:', err);
        }
        
        // Update leaderboard entry
        tx.set(leaderboardRef, {
          displayName: displayName,
          totalPoints: currentPoints + points,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      });
      
      console.log(`Updated leaderboard for ${ctx.params.uid}: +${points} points`);
    }
  });
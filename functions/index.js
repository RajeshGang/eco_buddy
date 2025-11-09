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
    for (const it of items) {
      const s = Number(it.score ?? 0);
      const qty = Number(it.qty ?? 1);
      const price = Number(it.unitPrice ?? 1);
      const weight = isFinite(price) && price > 0 ? qty * price : qty;
      sum += s * weight; w += weight;
    }
    const purchaseScore = w > 0 ? Math.round((sum / w) * 10) / 10 : null;
    await change.after.ref.update({ purchaseScore });
    const d = after.purchaseDate?.toDate ? after.purchaseDate.toDate() : new Date();
    const key = `${d.getFullYear()}${String(d.getMonth()+1).padStart(2,'0')}`;
    const aggRef = change.after.ref.parent.parent.collection('aggregates').doc('month').collection('all').doc(key);
    await admin.firestore().runTransaction(async (tx) => {
      const snap = await tx.get(aggRef);
      const prev = snap.exists ? snap.data() : { totalScore: 0, itemCount: 0 };
      const addCount = items.reduce((a,b)=> a + Number(b.qty||1), 0);
      tx.set(aggRef, { totalScore: (prev.totalScore||0) + (purchaseScore||0), itemCount: (prev.itemCount||0) + addCount }, { merge: true });
    });
  });
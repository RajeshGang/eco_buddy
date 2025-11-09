class PurchaseItem {
  final String? upc;
  final String description;
  final int qty;
  final double unitPrice;
  final String? category;
  final double? score;
  final String? scoreVersion;
  const PurchaseItem({this.upc, required this.description, required this.qty, required this.unitPrice, this.category, this.score, this.scoreVersion});
  Map<String, dynamic> toMap() => {
    'upc': upc,
    'description': description,
    'qty': qty,
    'unitPrice': unitPrice,
    'category': category,
    'score': score,
    'scoreVersion': scoreVersion,
  };
}

class Purchase {
  final String id;
  final String merchant;
  final DateTime purchaseDate;
  final double subtotal;
  final List<PurchaseItem> items;
  final String? receiptImagePath;
  final double? purchaseScore;
  const Purchase({required this.id, required this.merchant, required this.purchaseDate, required this.subtotal, required this.items, this.receiptImagePath, this.purchaseScore});
  Map<String, dynamic> toMap() => {
    'merchant': merchant,
    'purchaseDate': purchaseDate,
    'subtotal': subtotal,
    'items': items.map((e)=>e.toMap()).toList(),
    'receiptImagePath': receiptImagePath,
    'purchaseScore': purchaseScore,
  };
}

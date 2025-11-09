// Quick test to verify receipt parser works with your Costco receipt
// Run with: dart run test_receipt_parser.dart

import 'lib/features/scan/receipt_parser.dart';

void main() {
  // Your ACTUAL OCR text format from the app (items and prices on separate lines)
  final ocrText = '''
Photo
CosTOe
EWHOLESALE
Cümm ing #117B
1211 Bald Ridge Mar ina Rd
Cumming, GA 30041
A6 Member 111880736050
E
647465 AVOCADOS
1226620 WILDSALMNOIL
0000365888 /1226620
853472 0ADWOMEN 300
11438 AGED PARM
1587186 GILLETTE
521658 FERRERO 48CT
4.99 E
18.99 A
4.00-A
18.99 A
9.36 E
49.99 A
17.99 E
4.50-E
10.99 E
E
E 0000363444 / 521658
6995 GOLD KIWI
E
***********Bottom of
Basket**%********
***********BOB Count 0 **************
4234401 BLENDER
0000363457 /4234401
6148 PERSIMMONS
SUBTOTAL
TAX
**** TOTAL
XXXXXXXXXXX6383
AID: A0000000031010
Tran ID#: 531200011446.
App*: 09586D
Seg# 11446
Visa Resp: APPROVED
39.99 A
10.00-A
4.99 E
157.78
9.29
1601
E
''';

  print('🧪 Testing Receipt Parser\n');
  print('=' * 50);
  
  final items = ReceiptParser.parseReceipt(ocrText);
  
  print('\n📝 Extracted ${items.length} items:\n');
  
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    final category = ReceiptParser.categorizeItem(item.description);
    final score = ReceiptParser.estimateScore(item.description, category);
    
    print('${i + 1}. ${item.description}');
    print('   Price: \$${item.unitPrice.toStringAsFixed(2)}');
    print('   Category: $category');
    print('   Score: ${score.toStringAsFixed(0)}/100');
    print('');
  }
  
  if (items.isEmpty) {
    print('❌ NO ITEMS FOUND - Parser needs more work!');
  } else {
    print('✅ SUCCESS! Parser is working!');
  }
}

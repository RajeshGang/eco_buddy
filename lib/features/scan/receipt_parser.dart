/// Simple receipt parser to extract items from OCR text
class ReceiptParser {
  /// Parse receipt text and extract items
  static List<ReceiptItem> parseReceipt(String ocrText) {
    final items = <ReceiptItem>[];
    final lines = ocrText.split('\n');
    
    // Pattern to match standalone prices: "4.99 E", "18.99 A", "4.00-A", etc.
    final pricePattern = RegExp(r'^(\d+\.\d{2})\s*[-]?[A-Z]?\s*$');
    
    // Pattern to match item lines (has letters, not just numbers)
    final itemPattern = RegExp(r'[A-Z]{3,}');
    
    // First pass: collect all item names and all prices separately
    final List<String> itemNames = [];
    final List<double> prices = [];
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // Skip header/footer
      if (_isHeaderOrFooter(line)) continue;
      
      // Check if this is a price line
      final priceMatch = pricePattern.firstMatch(line);
      if (priceMatch != null) {
        final price = double.tryParse(priceMatch.group(1)!);
        if (price != null && price > 0 && price < 1000) {
          prices.add(price);
        }
        continue;
      }
      
      // Check if this line contains an item name
      if (itemPattern.hasMatch(line) && !line.contains('*')) {
        var itemName = line;
        
        // Remove leading codes and markers
        itemName = itemName.replaceAll(RegExp(r'^[E]\s+'), '').trim();
        itemName = itemName.replaceAll(RegExp(r'^\d{5,}\s+'), '').trim();
        itemName = itemName.replaceAll(RegExp(r'\d{10,}\s*/\s*\d+'), '').trim();
        itemName = itemName.replaceAll(RegExp(r'/\s*\d+'), '').trim();
        itemName = itemName.replaceAll(RegExp(r'^[\d/\s]+'), '').trim();
        
        // Skip if too short or looks like a code
        if (itemName.length >= 3 && itemPattern.hasMatch(itemName)) {
          // Skip common non-product terms
          final lower = itemName.toLowerCase();
          if (!lower.contains('member') && 
              !lower.contains('resp') && 
              !lower.contains('visa') &&
              !lower.contains('app#') &&
              !lower.contains('seg#') &&
              !lower.contains('aid:') &&
              !lower.contains('tran id') &&
              !lower.contains('approved') &&
              !lower.contains('wholesale') &&
              !lower.contains('costco') &&
              !lower.contains('photo') &&
              !lower.contains('cumm') &&
              !lower.contains('ridge') &&
              !lower.contains('bald') &&
              !itemName.contains('X') && // Skip card numbers like XXXXX
              !RegExp(r'^\d+$').hasMatch(itemName)) { // Skip pure numbers
            itemNames.add(itemName);
          }
        }
      }
    }
    
    // Second pass: match items with prices (assume they appear in order)
    final matchCount = itemNames.length < prices.length ? itemNames.length : prices.length;
    
    for (var i = 0; i < matchCount; i++) {
      items.add(ReceiptItem(
        description: _cleanItemName(itemNames[i]),
        quantity: 1,
        unitPrice: prices[i],
      ));
    }
    
    return items;
  }
  
  static bool _isHeaderOrFooter(String line) {
    final lower = line.toLowerCase();
    return lower.contains('total') ||
           lower.contains('subtotal') ||
           lower.contains('tax') ||
           lower.contains('thank you') ||
           lower.contains('receipt') ||
           lower.contains('store') ||
           lower.contains('date') ||
           lower.contains('time') ||
           lower.contains('cashier') ||
           lower.contains('card') ||
           lower.contains('change') ||
           lower.contains('tender') ||
           lower.length < 3;
  }
  
  static String _cleanItemName(String name) {
    // Remove extra spaces
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Capitalize first letter of each word
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Categorize item based on name
  static String categorizeItem(String itemName) {
    final lower = itemName.toLowerCase();
    
    // Food & Grocery - Produce
    if (lower.contains('avocado') || lower.contains('kiwi') || 
        lower.contains('persimmon') || lower.contains('apple') || 
        lower.contains('banana') || lower.contains('orange') || 
        lower.contains('fruit') || lower.contains('vegetable') || 
        lower.contains('lettuce') || lower.contains('tomato')) {
      return 'Food & Grocery';
    }
    
    // Food & Grocery - Dairy & Cheese
    if (lower.contains('milk') || lower.contains('cheese') || 
        lower.contains('yogurt') || lower.contains('butter') ||
        lower.contains('parm') || lower.contains('cheddar')) {
      return 'Food & Grocery';
    }
    
    // Food & Grocery - Pantry
    if (lower.contains('bread') || lower.contains('cereal') || 
        lower.contains('pasta') || lower.contains('rice') ||
        lower.contains('oil') || lower.contains('salmon')) {
      return 'Food & Grocery';
    }
    
    // Food & Grocery - Meat & Protein
    if (lower.contains('chicken') || lower.contains('beef') || 
        lower.contains('pork') || lower.contains('fish') || 
        lower.contains('meat') || lower.contains('salmon')) {
      return 'Food & Grocery';
    }
    
    // Food & Grocery - Snacks & Candy
    if (lower.contains('ferrero') || lower.contains('chocolate') ||
        lower.contains('candy') || lower.contains('snack')) {
      return 'Food & Grocery';
    }
    
    // Beverages
    if (lower.contains('water') || lower.contains('juice') || 
        lower.contains('soda') || lower.contains('coffee') || 
        lower.contains('tea') || lower.contains('drink')) {
      return 'Beverages';
    }
    
    // Personal Care
    if (lower.contains('gillette') || lower.contains('razor') ||
        lower.contains('shampoo') || lower.contains('soap') || 
        lower.contains('toothpaste') || lower.contains('deodorant') ||
        lower.contains('shave') || lower.contains('women') ||
        lower.contains('men')) {
      return 'Personal Care';
    }
    
    // Household - Appliances
    if (lower.contains('blender') || lower.contains('mixer') ||
        lower.contains('appliance') || lower.contains('kitchen')) {
      return 'Household';
    }
    
    // Household - Cleaning
    if (lower.contains('detergent') || lower.contains('cleaner') || 
        lower.contains('paper') || lower.contains('towel') || 
        lower.contains('tissue')) {
      return 'Household';
    }
    
    // Default
    return 'General';
  }
  
  /// Estimate base sustainability score for an item
  static double estimateScore(String itemName, String category) {
    final lower = itemName.toLowerCase();
    
    // Start with category-based scores
    double score = 50.0;
    
    // Category base adjustments
    if (category == 'Food & Grocery') {
      // Fresh produce gets high scores
      if (lower.contains('avocado') || lower.contains('kiwi') || 
          lower.contains('persimmon') || lower.contains('fruit')) {
        score = 75.0;
      }
      // Cheese and dairy - moderate
      else if (lower.contains('parm') || lower.contains('cheese')) {
        score = 60.0;
      }
      // Fish oil and supplements - good
      else if (lower.contains('salmon') || lower.contains('oil') || lower.contains('omega')) {
        score = 70.0;
      }
      // Candy and processed - lower
      else if (lower.contains('ferrero') || lower.contains('chocolate') || lower.contains('candy')) {
        score = 35.0;
      }
    } else if (category == 'Personal Care') {
      // Razors and disposables - lower
      if (lower.contains('gillette') || lower.contains('razor')) {
        score = 40.0;
      }
      // Women's health products
      else if (lower.contains('women') || lower.contains('adwomen')) {
        score = 55.0;
      }
    } else if (category == 'Household') {
      // Appliances - moderate (depends on energy efficiency)
      if (lower.contains('blender') || lower.contains('appliance')) {
        score = 55.0;
      }
    }
    
    // Positive modifiers
    if (lower.contains('organic')) score += 20;
    if (lower.contains('local')) score += 15;
    if (lower.contains('natural')) score += 10;
    if (lower.contains('eco') || lower.contains('green')) score += 15;
    if (lower.contains('reusable')) score += 20;
    if (lower.contains('bamboo')) score += 15;
    if (lower.contains('recycled')) score += 15;
    if (lower.contains('wild')) score += 10; // Wild caught fish
    
    // Negative modifiers
    if (lower.contains('plastic')) score -= 20;
    if (lower.contains('disposable')) score -= 15;
    if (lower.contains('single-use')) score -= 20;
    if (lower.contains('bottled')) score -= 10;
    if (lower.contains('processed')) score -= 10;
    
    // Clamp between 0 and 100
    return score.clamp(0, 100);
  }
}

class ReceiptItem {
  final String description;
  final int quantity;
  final double unitPrice;
  
  ReceiptItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });
  
  double get totalPrice => quantity * unitPrice;
}

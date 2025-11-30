import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductRecommendation {
  final String productName;
  final String description;
  final double estimatedScore;
  final String reasoning;
  final double? price; // Price in USD, nullable

  ProductRecommendation({
    required this.productName,
    required this.description,
    required this.estimatedScore,
    required this.reasoning,
    this.price,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      estimatedScore: (json['estimatedScore'] as num?)?.toDouble() ?? 0.0,
      reasoning: json['reasoning'] ?? '',
      price: (json['price'] as num?)?.toDouble(),
    );
  }
}

class AIRecommendationService {
  // Get your FREE Gemini API key from: https://aistudio.google.com/app/apikey
  static const String _apiKey = 'AIzaSyB0ZymrElEwfGUX8Bs7TRmZewPelz3UBsQ';
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<List<ProductRecommendation>> getRecommendations({
    required String productName,
    required String category,
    required double currentScore,
    int count = 3, // Default to 3 recommendations
  }) async {
    // If no API key, use smart mock data immediately
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return _getSmartRecommendations(productName, category, currentScore, count);
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''You are a sustainability expert recommending specific branded products. Given "$productName" in "$category" (current score: $currentScore/100), recommend $count SPECIFIC, REAL branded alternatives.

CRITICAL REQUIREMENTS:
1. Use REAL brand names (e.g., "Kirkland Signature Organic Chicken", "Seventh Generation Dish Soap", "Patagonia Recycled Fleece")
2. Be SPECIFIC - include product line, size, or variant (e.g., "Applegate Organic Turkey Bacon 8oz" not just "organic bacon")
3. Make each recommendation UNIQUE and DIFFERENT from each other
4. If the product is from Costco/warehouse stores, recommend other Costco/warehouse alternatives when possible
5. Include specific sustainability certifications (USDA Organic, Fair Trade, B Corp, etc.)
6. Vary the recommendation types: organic upgrade, different brand, bulk option, alternative material, etc.

SCORING GUIDELINES:
- Organic versions: +15-25 points
- Local/regional brands: +20-30 points
- Zero-waste/bulk options: +25-35 points
- B Corp/certified sustainable brands: +20-30 points
- Reusable/durable alternatives: +30-40 points

Return ONLY valid JSON (no markdown, no backticks):
[
  {
    "productName": "Specific Brand Name + Product Line",
    "description": "Detailed description with specific features, certifications, and what makes it unique",
    "estimatedScore": 85.0,
    "reasoning": "Specific environmental benefits with numbers/data when possible (e.g., '70% less plastic', 'carbon neutral certified')",
    "price": 12.99
  }
]

EXAMPLES:
- For "chicken": "Kirkland Signature Organic Free-Range Chicken" or "Mary's Organic Air-Chilled Chicken"
- For "razors": "Leaf Shave Safety Razor (Lifetime Warranty)" or "Preserve Triple Razor (100% Recycled Plastic)"
- For "chocolate": "Tony's Chocolonely Fair Trade Dark Chocolate" or "Alter Eco Organic Dark Chocolate Bars"

Now recommend for "$productName":'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        // Extract JSON from response
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final List<dynamic> recommendations = jsonDecode(jsonStr);
          
          return recommendations
              .map((rec) => ProductRecommendation.fromJson(rec))
              .toList();
        }
      }

      return _getSmartRecommendations(productName, category, currentScore, count);
    } catch (e) {
      print('Error getting AI recommendations: $e');
      return _getSmartRecommendations(productName, category, currentScore, count);
    }
  }

  // Smart recommendations based on category with specific brands
  List<ProductRecommendation> _getSmartRecommendations(
    String productName,
    String category,
    double currentScore,
    int count,
  ) {
    final cat = category.toLowerCase();
    final lower = productName.toLowerCase();
    
    // Category-specific recommendations with real brands
    if (cat.contains('food') || cat.contains('grocery')) {
      // Specific food product recommendations
      if (lower.contains('chicken')) {
        final allRecs = [
          ProductRecommendation(
            productName: 'Kirkland Signature Organic Free-Range Chicken',
            description: 'USDA Organic certified, antibiotic-free, raised on vegetarian feed. Air-chilled process uses 90% less water than conventional methods.',
            estimatedScore: (currentScore + 25).clamp(0, 100),
            reasoning: 'Organic certification eliminates pesticide exposure, free-range reduces stress, and air-chilling saves 30 gallons of water per bird.',
            price: 8.99,
          ),
          ProductRecommendation(
            productName: 'Mary\'s Organic Air-Chilled Chicken',
            description: 'Family-owned California brand, Non-GMO Project Verified, humanely raised with outdoor access. Carbon-neutral shipping program.',
            estimatedScore: (currentScore + 30).clamp(0, 100),
            reasoning: 'B Corp certified, supports regenerative agriculture practices, and 100% renewable energy in processing facilities.',
            price: 12.99,
          ),
          ProductRecommendation(
            productName: 'Bell & Evans Organic Chicken Breast',
            description: 'Third-generation family farm, certified humane, no antibiotics ever. Compostable packaging available.',
            estimatedScore: (currentScore + 28).clamp(0, 100),
            reasoning: 'American Humane Certified, uses solar power for 40% of operations, and partners with local feed suppliers to reduce transport emissions.',
            price: 11.49,
          ),
          ProductRecommendation(
            productName: 'Applegate Organic Chicken',
            description: 'USDA Organic, no antibiotics ever, humanely raised. Available at most grocery stores.',
            estimatedScore: (currentScore + 26).clamp(0, 100),
            reasoning: 'Certified organic, supports animal welfare, and uses sustainable farming practices.',
            price: 9.99,
          ),
          ProductRecommendation(
            productName: 'Whole Foods 365 Organic Chicken',
            description: 'Store brand organic option, affordable and widely available. Meets organic standards.',
            estimatedScore: (currentScore + 24).clamp(0, 100),
            reasoning: 'Organic certification, accessible pricing, and supports sustainable agriculture.',
            price: 7.99,
          ),
        ];
        return allRecs.take(count).toList();
      } else if (lower.contains('salmon') || lower.contains('fish')) {
        final allRecs = [
          ProductRecommendation(
            productName: 'Wild Planet Wild Alaskan Sockeye Salmon',
            description: 'MSC certified sustainable wild-caught, pole & line caught to reduce bycatch. BPA-free cans made from 25% recycled steel.',
            estimatedScore: (currentScore + 30).clamp(0, 100),
            reasoning: 'Wild-caught eliminates farm pollution, selective fishing protects marine ecosystems, and company is 1% for the Planet member.',
            price: 6.99,
          ),
          ProductRecommendation(
            productName: 'Vital Choice Wild Salmon (Frozen)',
            description: 'Certified sustainable by Marine Stewardship Council, flash-frozen within hours of catch. Carbon-neutral shipping with dry ice.',
            estimatedScore: (currentScore + 28).clamp(0, 100),
            reasoning: 'Traceability to specific fishing vessel, supports Alaska\'s sustainable fishery management, and uses recyclable packaging.',
            price: 18.99,
          ),
          ProductRecommendation(
            productName: 'Patagonia Provisions Wild Salmon',
            description: 'B Corp certified, traceable to fishing vessel, supports indigenous fishing communities. 100% of profits go to environmental causes.',
            estimatedScore: (currentScore + 35).clamp(0, 100),
            reasoning: 'Regenerative ocean farming practices, fair trade certified, and company donates 1% of sales to environmental nonprofits.',
            price: 24.99,
          ),
          ProductRecommendation(
            productName: 'Safe Catch Wild Pink Salmon',
            description: 'MSC certified, tested for mercury, sustainably caught. BPA-free packaging.',
            estimatedScore: (currentScore + 27).clamp(0, 100),
            reasoning: 'Mercury tested for safety, sustainable fishing practices, and responsible sourcing.',
            price: 5.99,
          ),
          ProductRecommendation(
            productName: 'Whole Foods 365 Wild Caught Salmon',
            description: 'Store brand wild-caught option, MSC certified, affordable.',
            estimatedScore: (currentScore + 25).clamp(0, 100),
            reasoning: 'Wild-caught, sustainable certification, and accessible pricing.',
            price: 12.99,
          ),
        ];
        return allRecs.take(count).toList();
      } else if (lower.contains('chocolate') || lower.contains('candy')) {
        final allRecs = [
          ProductRecommendation(
            productName: 'Tony\'s Chocolonely Dark Chocolate Bar',
            description: 'Fair Trade certified, slave-free cocoa mission, B Corp certified. Traceable beans from Ghana and Ivory Coast cooperatives.',
            estimatedScore: (currentScore + 35).clamp(0, 100),
            reasoning: 'Pays 40% premium to farmers, 100% traceable supply chain, and actively fights child labor in cocoa industry.',
            price: 4.99,
          ),
          ProductRecommendation(
            productName: 'Alter Eco Organic Dark Chocolate',
            description: 'USDA Organic, Fair Trade, carbon neutral certified. Compostable wrappers made from plant-based materials.',
            estimatedScore: (currentScore + 32).clamp(0, 100),
            reasoning: 'Offsets 100% of carbon emissions, supports small farmer cooperatives, and uses renewable energy in production.',
            price: 5.49,
          ),
          ProductRecommendation(
            productName: 'Equal Exchange Organic Chocolate',
            description: 'Worker-owned cooperative, Fair Trade for 30+ years, organic certified. Direct trade with farmer co-ops.',
            estimatedScore: (currentScore + 30).clamp(0, 100),
            reasoning: 'Democratic ownership model, pays farmers 3x market rate, and invests in community development projects.',
            price: 4.49,
          ),
          ProductRecommendation(
            productName: 'Green & Black\'s Organic Dark Chocolate',
            description: 'Fair Trade, organic certified, rich flavor. Available at most grocery stores.',
            estimatedScore: (currentScore + 28).clamp(0, 100),
            reasoning: 'Fair Trade and organic certifications, supports sustainable farming practices.',
            price: 3.99,
          ),
          ProductRecommendation(
            productName: 'Endangered Species Chocolate',
            description: '10% of profits to wildlife conservation, Fair Trade, non-GMO. Various flavors available.',
            estimatedScore: (currentScore + 29).clamp(0, 100),
            reasoning: 'Supports wildlife conservation, Fair Trade certified, and ethical sourcing.',
            price: 4.29,
          ),
        ];
        return allRecs.take(count).toList();
      } else if (lower.contains('avocado')) {
        final allRecs = [
          ProductRecommendation(
            productName: 'Local Organic Avocados (Farmers Market)',
            description: 'Seasonally available from California or Florida growers. Zero packaging, minimal transport, supports local agriculture.',
            estimatedScore: (currentScore + 20).clamp(0, 100),
            reasoning: 'Eliminates cross-country shipping (saves 2kg CO₂ per lb), no plastic packaging, and keeps money in local economy.',
            price: 2.50,
          ),
          ProductRecommendation(
            productName: 'Imperfect Foods "Ugly" Avocados',
            description: 'Cosmetically imperfect avocados rescued from waste. Same quality, 30% less cost, delivered in reusable boxes.',
            estimatedScore: (currentScore + 25).clamp(0, 100),
            reasoning: 'Prevents food waste (40% of avocados rejected for appearance), carbon-neutral delivery, and reduces landfill methane.',
            price: 1.75,
          ),
          ProductRecommendation(
            productName: 'GoodFarms Organic Avocados (Regenerative)',
            description: 'Regenerative agriculture certified, biodiversity-focused farming. Uses cover crops and no-till methods.',
            estimatedScore: (currentScore + 30).clamp(0, 100),
            reasoning: 'Sequesters 3 tons CO₂ per acre annually, improves soil health, and provides habitat for 200+ species.',
            price: 2.99,
          ),
          ProductRecommendation(
            productName: 'Whole Foods 365 Organic Avocados',
            description: 'USDA Organic certified, available year-round. Supports sustainable farming.',
            estimatedScore: (currentScore + 22).clamp(0, 100),
            reasoning: 'Organic certification, accessible pricing, and supports sustainable agriculture.',
            price: 2.29,
          ),
          ProductRecommendation(
            productName: 'Trader Joe\'s Organic Avocados',
            description: 'Affordable organic option, widely available. Meets organic standards.',
            estimatedScore: (currentScore + 21).clamp(0, 100),
            reasoning: 'Organic certification and budget-friendly pricing.',
            price: 1.99,
          ),
        ];
        return allRecs.take(count).toList();
      } else {
        // Generic food recommendations with brands
        final allRecs = [
          ProductRecommendation(
            productName: 'Organic Valley ${productName.split(' ').first}',
            description: 'Farmer-owned cooperative, USDA Organic certified, pasture-raised standards. Supports 1,800+ family farms across the US.',
            estimatedScore: (currentScore + 25).clamp(0, 100),
            reasoning: 'Cooperative model ensures fair farmer pay, organic practices eliminate synthetic pesticides, and regenerative grazing sequesters carbon.',
            price: 6.99,
          ),
          ProductRecommendation(
            productName: 'Thrive Market Organic ${productName.split(' ').first}',
            description: 'B Corp certified online retailer, carbon-neutral shipping, donates membership to low-income families. Bulk packaging options.',
            estimatedScore: (currentScore + 22).clamp(0, 100),
            reasoning: 'Offsets 100% of shipping emissions, reduces packaging by 30%, and social mission provides access to healthy food.',
            price: 5.99,
          ),
          ProductRecommendation(
            productName: 'Bulk Bin ${productName.split(' ').first} (Zero Waste)',
            description: 'Available at Whole Foods, Sprouts, or local co-ops. Bring your own container, pay by weight, eliminate packaging.',
            estimatedScore: (currentScore + 35).clamp(0, 100),
            reasoning: 'Zero single-use packaging, reduces food waste by buying exact amounts, and typically 20-40% cheaper than packaged.',
            price: 4.99,
          ),
          ProductRecommendation(
            productName: 'Whole Foods 365 Organic ${productName.split(' ').first}',
            description: 'Store brand organic option, affordable and widely available. Meets organic standards.',
            estimatedScore: (currentScore + 23).clamp(0, 100),
            reasoning: 'Organic certification, accessible pricing, and supports sustainable agriculture.',
            price: 5.49,
          ),
          ProductRecommendation(
            productName: 'Local Farmers Market ${productName.split(' ').first}',
            description: 'Direct from local farmers, seasonal availability, minimal packaging. Supports local economy.',
            estimatedScore: (currentScore + 27).clamp(0, 100),
            reasoning: 'Reduces transportation emissions, supports local farmers, and typically fresher produce.',
            price: 4.49,
          ),
        ];
        return allRecs.take(count).toList();
      }
    } else if (cat.contains('cleaning') || cat.contains('household')) {
      final allRecs = [
        ProductRecommendation(
          productName: 'Seventh Generation Plant-Based ${productName}',
          description: 'Made from biodegradable plant ingredients. Works just as effectively without harsh chemicals. B Corp certified.',
          estimatedScore: currentScore + 28,
          reasoning: 'Biodegrades 95% faster than chemical alternatives and safe for aquatic ecosystems.',
          price: 4.99,
        ),
        ProductRecommendation(
          productName: 'Blueland ${productName} Concentrate Refill',
          description: 'Concentrated tablets, reusable forever bottles, plastic-free refills. Mix with water at home to reduce shipping weight.',
          estimatedScore: currentScore + 32,
          reasoning: 'Reduces packaging waste by 80% and cuts transportation emissions by 60%.',
          price: 12.99,
        ),
        ProductRecommendation(
          productName: 'Multi-Purpose Cleaner (DIY Recipe)',
          description: 'Make your own with vinegar, baking soda, and essential oils. Equally effective and eco-friendly.',
          estimatedScore: currentScore + 40,
          reasoning: 'Zero plastic waste, minimal carbon footprint, and uses common household ingredients.',
          price: 2.50,
        ),
        ProductRecommendation(
          productName: 'Method Plant-Based ${productName}',
          description: 'Biodegradable formula, recyclable packaging, cruelty-free. Available at most stores.',
          estimatedScore: currentScore + 26,
          reasoning: 'Plant-based ingredients, sustainable packaging, and effective cleaning power.',
          price: 3.99,
        ),
        ProductRecommendation(
          productName: 'Mrs. Meyer\'s Clean Day ${productName}',
          description: 'Plant-derived ingredients, essential oils, biodegradable. Pleasant scents available.',
          estimatedScore: currentScore + 24,
          reasoning: 'Plant-based formula, cruelty-free, and effective cleaning.',
          price: 4.49,
        ),
      ];
      return allRecs.take(count).toList();
    } else if (cat.contains('personal care') || cat.contains('beauty')) {
      if (lower.contains('razor') || lower.contains('gillette')) {
        final allRecs = [
          ProductRecommendation(
            productName: 'Leaf Shave Safety Razor (Lifetime Warranty)',
            description: 'All-metal construction, accepts standard blades (\$0.10 each), pivoting head. Made in USA, plastic-free packaging.',
            estimatedScore: (currentScore + 45).clamp(0, 100),
            reasoning: 'One razor replaces 100+ disposables, blades are 100% recyclable steel, and saves \$200+ per year vs cartridges.',
            price: 84.99,
          ),
          ProductRecommendation(
            productName: 'Preserve Triple Razor (100% Recycled Plastic)',
            description: 'Made from recycled yogurt cups, replaceable cartridges, mail-back recycling program. B Corp certified.',
            estimatedScore: (currentScore + 30).clamp(0, 100),
            reasoning: 'Diverts 5 yogurt cups from landfills per razor, closed-loop recycling system, and carbon-neutral manufacturing.',
            price: 8.99,
          ),
          ProductRecommendation(
            productName: 'Rockwell Razors R1 Safety Razor',
            description: 'Beginner-friendly safety razor, chrome-plated brass, includes 5 blades. Lifetime warranty, plastic-free.',
            estimatedScore: (currentScore + 40).clamp(0, 100),
            reasoning: 'Eliminates 95% of plastic waste, blades cost 90% less than cartridges, and built to last generations.',
            price: 29.99,
          ),
          ProductRecommendation(
            productName: 'Merkur Classic Safety Razor',
            description: 'German-made precision razor, double-edge blades, durable construction. Classic design.',
            estimatedScore: (currentScore + 38).clamp(0, 100),
            reasoning: 'Long-lasting design, recyclable blades, and eliminates plastic waste.',
            price: 39.99,
          ),
          ProductRecommendation(
            productName: 'Van Der Hagen Safety Razor',
            description: 'Affordable safety razor option, includes blades, beginner-friendly. Plastic-free.',
            estimatedScore: (currentScore + 35).clamp(0, 100),
            reasoning: 'Budget-friendly option, eliminates disposable razors, and recyclable blades.',
            price: 19.99,
          ),
        ];
        return allRecs.take(count).toList();
      } else if (lower.contains('shampoo') || lower.contains('soap')) {
        final allRecs = [
          ProductRecommendation(
            productName: 'Ethique Solid Shampoo Bar',
            description: 'New Zealand B Corp, plastic-free, vegan, cruelty-free. One bar = 3 bottles. Compostable packaging.',
            estimatedScore: (currentScore + 38).clamp(0, 100),
            reasoning: 'Prevents 3 plastic bottles, carbon-neutral certified, and concentrated formula reduces shipping emissions by 70%.',
            price: 14.99,
          ),
          ProductRecommendation(
            productName: 'Plaine Products Refillable Shampoo',
            description: 'Aluminum bottle subscription, return empties for refill. Plant-based, sulfate-free, made in USA.',
            estimatedScore: (currentScore + 35).clamp(0, 100),
            reasoning: 'Reusable bottle system eliminates 95% of packaging, carbon-neutral shipping, and supports circular economy.',
            price: 24.99,
          ),
          ProductRecommendation(
            productName: 'Dr. Bronner\'s Castile Soap (Bulk)',
            description: 'Fair Trade, organic, multi-use (body, hair, cleaning). Available in bulk at co-ops. B Corp certified.',
            estimatedScore: (currentScore + 32).clamp(0, 100),
            reasoning: 'One product replaces 10+ bottles, Fair Trade supports farmers, and regenerative organic practices sequester carbon.',
            price: 12.99,
          ),
          ProductRecommendation(
            productName: 'HiBAR Solid Shampoo Bar',
            description: 'Plastic-free, vegan, cruelty-free. One bar lasts 2-3 months. Various formulas available.',
            estimatedScore: (currentScore + 36).clamp(0, 100),
            reasoning: 'Eliminates plastic bottles, concentrated formula, and long-lasting.',
            price: 12.99,
          ),
          ProductRecommendation(
            productName: 'J.R. Liggett\'s Shampoo Bar',
            description: 'All-natural ingredients, no plastic packaging, one bar = multiple bottles. Simple formula.',
            estimatedScore: (currentScore + 34).clamp(0, 100),
            reasoning: 'Plastic-free, natural ingredients, and reduces packaging waste.',
            price: 7.99,
          ),
        ];
        return allRecs.take(count).toList();
      } else {
        final allRecs = [
          ProductRecommendation(
            productName: 'Package Free Shop ${productName.split(' ').first}',
            description: 'Zero-waste specialty retailer, plastic-free packaging, B Corp certified. Curated sustainable alternatives.',
            estimatedScore: (currentScore + 30).clamp(0, 100),
            reasoning: 'Eliminates single-use plastic, carbon-neutral shipping, and supports small sustainable brands.',
            price: 15.99,
          ),
          ProductRecommendation(
            productName: 'Blueland ${productName.split(' ').first} Tablets',
            description: 'Concentrated tablets, reusable forever bottles, plastic-free refills. B Corp, carbon-neutral.',
            estimatedScore: (currentScore + 35).clamp(0, 100),
            reasoning: 'Eliminates 99% of plastic packaging, reduces shipping weight by 95%, and prevents 100 billion plastic bottles.',
            price: 12.99,
          ),
          ProductRecommendation(
            productName: 'Native Deodorant (Plastic-Free)',
            description: 'Aluminum-free, paper tube packaging, cruelty-free. Subscription available with carbon-neutral shipping.',
            estimatedScore: (currentScore + 28).clamp(0, 100),
            reasoning: 'Compostable packaging, no harsh chemicals, and B Corp certified with transparent ingredient sourcing.',
            price: 12.99,
          ),
          ProductRecommendation(
            productName: 'Lush Naked ${productName.split(' ').first}',
            description: 'Solid format, no packaging, handmade. Available at Lush stores and online.',
            estimatedScore: (currentScore + 32).clamp(0, 100),
            reasoning: 'Zero packaging waste, handmade with natural ingredients, and supports ethical sourcing.',
            price: 9.99,
          ),
          ProductRecommendation(
            productName: 'Well Earth Goods ${productName.split(' ').first}',
            description: 'Plastic-free, natural ingredients, zero-waste options. Available online.',
            estimatedScore: (currentScore + 29).clamp(0, 100),
            reasoning: 'Eliminates plastic packaging, natural ingredients, and supports sustainable practices.',
            price: 11.99,
          ),
        ];
        return allRecs.take(count).toList();
      }
    } else {
      // Generic sustainable alternatives
      final allRecs = [
        ProductRecommendation(
          productName: 'Eco-Friendly ${productName}',
          description: 'Sustainable version made from recycled materials with minimal packaging and carbon-neutral shipping.',
          estimatedScore: currentScore + 20,
          reasoning: 'Uses 60% recycled content and biodegradable packaging, reducing waste by 75%.',
          price: 19.99,
        ),
        ProductRecommendation(
          productName: 'Durable ${productName} (Lifetime Guarantee)',
          description: 'Higher quality, longer-lasting alternative designed for repair rather than replacement.',
          estimatedScore: currentScore + 25,
          reasoning: 'Lasts 5x longer than standard products, dramatically reducing per-use environmental impact.',
          price: 49.99,
        ),
        ProductRecommendation(
          productName: 'Second-Hand/Refurbished ${productName}',
          description: 'Certified pre-owned or refurbished version. Fully functional with warranty at lower environmental cost.',
          estimatedScore: currentScore + 40,
          reasoning: 'Reusing existing products avoids 100% of manufacturing emissions and reduces waste.',
          price: 29.99,
        ),
        ProductRecommendation(
          productName: 'Bulk ${productName} (Zero Waste)',
          description: 'Available in bulk at co-ops or zero-waste stores. Bring your own container.',
          estimatedScore: currentScore + 30,
          reasoning: 'Eliminates packaging waste, reduces cost, and supports zero-waste lifestyle.',
          price: 14.99,
        ),
        ProductRecommendation(
          productName: 'Local Artisan ${productName}',
          description: 'Handmade by local artisans, minimal packaging, supports local economy.',
          estimatedScore: currentScore + 22,
          reasoning: 'Reduces transportation emissions, supports local economy, and often higher quality.',
          price: 24.99,
        ),
      ];
      return allRecs.take(count).toList();
    }
  }
}
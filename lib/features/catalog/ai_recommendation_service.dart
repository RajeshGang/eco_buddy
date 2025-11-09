import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductRecommendation {
  final String productName;
  final String description;
  final double estimatedScore;
  final String reasoning;

  ProductRecommendation({
    required this.productName,
    required this.description,
    required this.estimatedScore,
    required this.reasoning,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      estimatedScore: (json['estimatedScore'] as num?)?.toDouble() ?? 0.0,
      reasoning: json['reasoning'] ?? '',
    );
  }
}

class AIRecommendationService {
  // NOTE: In production, you should store your API key securely
  // For now, we'll use a placeholder - you'll need to add your actual key
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY_HERE';
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';

  Future<List<ProductRecommendation>> getRecommendations({
    required String productName,
    required String category,
    required double currentScore,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-5-sonnet-20241022',
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': '''Given a product "${productName}" in category "${category}" with a current sustainability score of ${currentScore}/100, 
recommend 3 more sustainable alternative products.

For each recommendation, provide:
1. Product name
2. Brief description (2-3 sentences)
3. Estimated sustainability score (0-100)
4. Reasoning for why it's more sustainable

Return your response as a JSON array with this exact structure:
[
  {
    "productName": "Alternative Product Name",
    "description": "Brief description of the product",
    "estimatedScore": 85.0,
    "reasoning": "Why this is more sustainable"
  }
]

Focus on real, available products when possible. Consider factors like:
- Recyclability and packaging
- Carbon footprint
- Local/organic sourcing
- Fair trade certifications
- Durability and longevity
- Company sustainability practices

Return ONLY the JSON array, no other text.'''
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;
        
        // Extract JSON from response
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final List<dynamic> recommendations = jsonDecode(jsonStr);
          
          return recommendations
              .map((rec) => ProductRecommendation.fromJson(rec))
              .toList();
        }
      }

      // Fallback to mock data if API fails
      return _getMockRecommendations(productName, category, currentScore);
    } catch (e) {
      print('Error getting AI recommendations: $e');
      return _getMockRecommendations(productName, category, currentScore);
    }
  }

  // Mock recommendations as fallback
  List<ProductRecommendation> _getMockRecommendations(
    String productName,
    String category,
    double currentScore,
  ) {
    return [
      ProductRecommendation(
        productName: 'Eco-Friendly Alternative',
        description:
            'A more sustainable version made from recycled materials with minimal packaging.',
        estimatedScore: currentScore + 20,
        reasoning:
            'Uses 50% recycled content and biodegradable packaging, reducing waste and carbon footprint.',
      ),
      ProductRecommendation(
        productName: 'Local Organic Option',
        description:
            'Locally sourced organic product that supports sustainable farming practices.',
        estimatedScore: currentScore + 25,
        reasoning:
            'Reduces transportation emissions and supports local economy while avoiding harmful pesticides.',
      ),
      ProductRecommendation(
        productName: 'Zero-Waste Solution',
        description:
            'A refillable or reusable alternative that eliminates single-use waste.',
        estimatedScore: currentScore + 30,
        reasoning:
            'Designed for longevity and reuse, significantly reducing overall environmental impact.',
      ),
    ];
  }
}
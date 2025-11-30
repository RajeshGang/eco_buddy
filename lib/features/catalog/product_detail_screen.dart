import 'package:flutter/material.dart';
import '../catalog/ai_recommendation_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productName;
  final String category;
  final double score;

  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.category,
    required this.score,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _aiService = AIRecommendationService();
  List<ProductRecommendation>? _recommendations;
  bool _loading = false;
  String? _error;
  int _recommendationCount = 3;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final recs = await _aiService.getRecommendations(
        productName: widget.productName,
        category: widget.category,
        currentScore: widget.score,
        count: _recommendationCount,
      );

      if (mounted) {
        setState(() {
          _recommendations = recs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Product Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productName,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: ${widget.category}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Sustainability Score: '),
                      const SizedBox(width: 8),
                      _ScoreBadge(score: widget.score),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recommendations Header
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Better Alternatives',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButton<int>(
                value: _recommendationCount,
                items: [3, 5, 7, 10].map((count) {
                  return DropdownMenuItem<int>(
                    value: count,
                    child: Text('$count suggestions'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _recommendationCount = value;
                    });
                    _loadRecommendations();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'AI-powered recommendations for more sustainable choices',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Recommendations List
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Error loading recommendations',
                        style: TextStyle(color: Colors.red[900])),
                    TextButton(
                      onPressed: _loadRecommendations,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_recommendations != null)
            ..._recommendations!.asMap().entries.map((entry) => _RecommendationCard(
                  recommendation: entry.value,
                  currentScore: widget.score,
                  index: entry.key,
                ))
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recommendations available'),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final ProductRecommendation recommendation;
  final double currentScore;
  final int index;

  const _RecommendationCard({
    required this.recommendation,
    required this.currentScore,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final improvement = recommendation.estimatedScore - currentScore;
    final isSponsored = index < 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSponsored
            ? BorderSide(color: Colors.amber[600]!, width: 2)
            : BorderSide.none,
      ),
      elevation: isSponsored ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSponsored) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber[600]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber[900]),
                              const SizedBox(width: 4),
                              Text(
                                'Sponsored',
                                style: TextStyle(
                                  color: Colors.amber[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        recommendation.productName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ScoreBadge(score: recommendation.estimatedScore),
              ],
            ),
            if (improvement > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '+${improvement.toStringAsFixed(0)} points',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (recommendation.price != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      '\$${recommendation.price!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              recommendation.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.eco, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.reasoning,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (score >= 75) {
      color = Colors.green;
    } else if (score >= 50) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        score.toStringAsFixed(0),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
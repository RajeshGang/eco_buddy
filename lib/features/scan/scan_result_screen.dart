import 'package:flutter/material.dart';
import '../catalog/ai_recommendation_service.dart';
import '../catalog/leaderboard_service.dart';
import '../catalog/product_detail_screen.dart';

/// Unified screen to display scan results with score and AI recommendations
class ScanResultScreen extends StatefulWidget {
  final String productName;
  final String category;
  final double score;
  final String? brand;
  final String? upc;
  final bool awardPoints; // Whether to award points (false for receipt items)

  const ScanResultScreen({
    super.key,
    required this.productName,
    required this.category,
    required this.score,
    this.brand,
    this.upc,
    this.awardPoints = true, // Default to true for barcode scans
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final _aiService = AIRecommendationService();
  final _leaderboardService = LeaderboardService();
  List<ProductRecommendation>? _recommendations;
  bool _loading = false;
  bool _pointsAwarded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
    _awardPoints();
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

  Future<void> _awardPoints() async {
    if (_pointsAwarded || !widget.awardPoints) return; // Skip if flag is false
    
    try {
      await _leaderboardService.awardPointsForPurchase(widget.score);
      if (mounted) {
        setState(() => _pointsAwarded = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Earned ${widget.score.round()} points!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error awarding points: $e');
    }
  }

  Map<String, dynamic> _calculateScoreBreakdown() {
    final lower = widget.productName.toLowerCase();
    final category = widget.category;
    
    // Base score by category
    double baseScore = 50.0;
    String baseReason = 'Standard baseline for all products';
    
    if (category == 'Food & Grocery') {
      if (lower.contains('avocado') || lower.contains('kiwi') || 
          lower.contains('persimmon') || lower.contains('fruit')) {
        baseScore = 75.0;
        baseReason = 'Fresh produce - minimal processing, natural';
      } else if (lower.contains('parm') || lower.contains('cheese')) {
        baseScore = 60.0;
        baseReason = 'Dairy product - moderate environmental impact';
      } else if (lower.contains('salmon') || lower.contains('oil')) {
        baseScore = 70.0;
        baseReason = 'Nutritional supplement - health benefits';
      } else if (lower.contains('ferrero') || lower.contains('chocolate')) {
        baseScore = 35.0;
        baseReason = 'Processed snack - high packaging, sugar content';
      }
    } else if (category == 'Personal Care') {
      if (lower.contains('gillette') || lower.contains('razor')) {
        baseScore = 40.0;
        baseReason = 'Disposable product - generates waste';
      } else {
        baseScore = 55.0;
        baseReason = 'Personal care item - moderate impact';
      }
    } else if (category == 'Household') {
      baseScore = 55.0;
      baseReason = 'Household item - long-term use reduces waste';
    }
    
    // Positive modifiers
    final List<Map<String, dynamic>> positiveFactors = [];
    if (lower.contains('organic')) {
      positiveFactors.add({'name': 'Organic', 'points': 20.0, 'reason': 'No synthetic pesticides or fertilizers'});
    }
    if (lower.contains('wild')) {
      positiveFactors.add({'name': 'Wild-caught', 'points': 10.0, 'reason': 'Natural sourcing, less farming impact'});
    }
    if (lower.contains('local')) {
      positiveFactors.add({'name': 'Local', 'points': 15.0, 'reason': 'Reduced transportation emissions'});
    }
    if (lower.contains('natural')) {
      positiveFactors.add({'name': 'Natural', 'points': 10.0, 'reason': 'Minimal chemical processing'});
    }
    if (lower.contains('eco') || lower.contains('green')) {
      positiveFactors.add({'name': 'Eco-friendly', 'points': 15.0, 'reason': 'Environmentally conscious design'});
    }
    if (lower.contains('reusable')) {
      positiveFactors.add({'name': 'Reusable', 'points': 20.0, 'reason': 'Eliminates single-use waste'});
    }
    if (lower.contains('bamboo')) {
      positiveFactors.add({'name': 'Bamboo', 'points': 15.0, 'reason': 'Sustainable, fast-growing material'});
    }
    if (lower.contains('recycled')) {
      positiveFactors.add({'name': 'Recycled', 'points': 15.0, 'reason': 'Reduces virgin material demand'});
    }
    
    // Negative modifiers
    final List<Map<String, dynamic>> negativeFactors = [];
    if (lower.contains('plastic')) {
      negativeFactors.add({'name': 'Plastic', 'points': -20.0, 'reason': 'Non-biodegradable, pollution risk'});
    }
    if (lower.contains('disposable')) {
      negativeFactors.add({'name': 'Disposable', 'points': -15.0, 'reason': 'Single-use generates waste'});
    }
    if (lower.contains('single-use')) {
      negativeFactors.add({'name': 'Single-use', 'points': -20.0, 'reason': 'Maximum waste generation'});
    }
    if (lower.contains('bottled')) {
      negativeFactors.add({'name': 'Bottled', 'points': -10.0, 'reason': 'Packaging waste, transport emissions'});
    }
    if (lower.contains('processed')) {
      negativeFactors.add({'name': 'Processed', 'points': -10.0, 'reason': 'Energy-intensive manufacturing'});
    }
    
    // Calculate total
    double totalPositive = positiveFactors.fold(0.0, (sum, f) => sum + f['points']);
    double totalNegative = negativeFactors.fold(0.0, (sum, f) => sum + f['points']);
    double finalScore = (baseScore + totalPositive + totalNegative).clamp(0, 100);
    
    // Estimate carbon footprint (simplified)
    double carbonFootprint = 0.0;
    String carbonUnit = 'kg CO₂e';
    
    if (category == 'Food & Grocery') {
      if (lower.contains('fruit') || lower.contains('vegetable')) {
        carbonFootprint = 0.5; // Low impact
      } else if (lower.contains('cheese') || lower.contains('dairy')) {
        carbonFootprint = 5.0; // High dairy impact
      } else if (lower.contains('fish') || lower.contains('salmon')) {
        carbonFootprint = 3.0; // Moderate seafood impact
      } else {
        carbonFootprint = 2.0; // Average food
      }
    } else if (category == 'Personal Care') {
      carbonFootprint = 1.5;
    } else if (category == 'Household') {
      carbonFootprint = 8.0; // Appliances have higher manufacturing impact
    }
    
    return {
      'baseScore': baseScore,
      'baseReason': baseReason,
      'positiveFactors': positiveFactors,
      'negativeFactors': negativeFactors,
      'totalPositive': totalPositive,
      'totalNegative': totalNegative,
      'finalScore': finalScore,
      'carbonFootprint': carbonFootprint,
      'carbonUnit': carbonUnit,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Done',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Product Info Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.brand != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.brand!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.category),
                        backgroundColor: Colors.blue[100],
                      ),
                      if (widget.upc != null) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('UPC: ${widget.upc}'),
                          backgroundColor: Colors.grey[200],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sustainability Score',
                        style: theme.textTheme.titleMedium,
                      ),
                      _ScoreBadge(score: widget.score),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: widget.score / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(widget.score),
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getScoreDescription(widget.score),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Score Breakdown Section
          _ScoreBreakdownCard(breakdown: _calculateScoreBreakdown()),
          const SizedBox(height: 24),

          // Recommendations Section
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                'Better Alternatives',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Finding better alternatives...'),
                  ],
                ),
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
                    Text(
                      'Error loading recommendations',
                      style: TextStyle(color: Colors.red[900]),
                    ),
                    TextButton(
                      onPressed: _loadRecommendations,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_recommendations != null && _recommendations!.isNotEmpty)
            ..._recommendations!.map((rec) => _RecommendationCard(
                  recommendation: rec,
                  currentScore: widget.score,
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

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(double score) {
    if (score >= 90) return 'Excellent! This is a highly sustainable choice.';
    if (score >= 75) return 'Great! This is a good sustainable option.';
    if (score >= 50) return 'Fair. There are better sustainable alternatives.';
    return 'Poor. Consider switching to a more sustainable option.';
  }
}

class _ScoreBreakdownCard extends StatefulWidget {
  final Map<String, dynamic> breakdown;

  const _ScoreBreakdownCard({required this.breakdown});

  @override
  State<_ScoreBreakdownCard> createState() => _ScoreBreakdownCardState();
}

class _ScoreBreakdownCardState extends State<_ScoreBreakdownCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final breakdown = widget.breakdown;
    final positiveFactors = breakdown['positiveFactors'] as List<Map<String, dynamic>>;
    final negativeFactors = breakdown['negativeFactors'] as List<Map<String, dynamic>>;

    return Card(
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Colors.blue[700],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score Breakdown',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'See how this score is calculated',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Base Score
                  _buildSectionHeader('Base Score', Icons.foundation),
                  const SizedBox(height: 8),
                  _buildScoreItem(
                    'Category: ${breakdown['baseReason']}',
                    breakdown['baseScore'],
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  // Positive Factors
                  if (positiveFactors.isNotEmpty) ...[
                    _buildSectionHeader('Positive Factors', Icons.add_circle_outline),
                    const SizedBox(height: 8),
                    ...positiveFactors.map((factor) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildFactorItem(
                        factor['name'],
                        factor['reason'],
                        factor['points'],
                        Colors.green,
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],

                  // Negative Factors
                  if (negativeFactors.isNotEmpty) ...[
                    _buildSectionHeader('Negative Factors', Icons.remove_circle_outline),
                    const SizedBox(height: 8),
                    ...negativeFactors.map((factor) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildFactorItem(
                        factor['name'],
                        factor['reason'],
                        factor['points'],
                        Colors.red,
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],

                  // Carbon Footprint Estimate
                  _buildSectionHeader('Carbon Footprint Estimate', Icons.cloud_outlined),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.eco, color: Colors.orange[700], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '~${breakdown['carbonFootprint'].toStringAsFixed(1)} ${breakdown['carbonUnit']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Estimated CO₂ equivalent emissions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Final Calculation
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildCalculationSummary(breakdown),
                  const SizedBox(height: 12),
                  
                  // Methodology Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Scores are calculated based on product category, sustainability attributes, packaging, and estimated environmental impact. Carbon footprint estimates are simplified and based on industry averages.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreItem(String label, double points, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ),
          Text(
            '${points.toStringAsFixed(0)} pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorItem(String name, String reason, double points, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                '${points > 0 ? '+' : ''}${points.toStringAsFixed(0)} pts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reason,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationSummary(Map<String, dynamic> breakdown) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Base Score:', style: TextStyle(fontSize: 13)),
            Text(
              '${breakdown['baseScore'].toStringAsFixed(0)} pts',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (breakdown['totalPositive'] > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Positive Factors:', style: TextStyle(fontSize: 13)),
              Text(
                '+${breakdown['totalPositive'].toStringAsFixed(0)} pts',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
        if (breakdown['totalNegative'] < 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Negative Factors:', style: TextStyle(fontSize: 13)),
              Text(
                '${breakdown['totalNegative'].toStringAsFixed(0)} pts',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Final Score:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              '${breakdown['finalScore'].toStringAsFixed(0)} / 100',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final ProductRecommendation recommendation;
  final double currentScore;

  const _RecommendationCard({
    required this.recommendation,
    required this.currentScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final improvement = recommendation.estimatedScore - currentScore;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    recommendation.productName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                    const Icon(Icons.trending_up, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '+${improvement.toStringAsFixed(0)} points better',
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[900],
                      ),
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

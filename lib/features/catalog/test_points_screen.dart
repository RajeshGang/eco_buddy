import 'package:flutter/material.dart';
import '../catalog/leaderboard_service.dart';
import '../catalog/ai_recommendation_service.dart';
import 'product_detail_screen.dart';

/// Demo screen to test points and AI recommendations
class TestPointsScreen extends StatefulWidget {
  const TestPointsScreen({super.key});

  @override
  State<TestPointsScreen> createState() => _TestPointsScreenState();
}

class _TestPointsScreenState extends State<TestPointsScreen> {
  final _leaderboardService = LeaderboardService();
  bool _loading = false;

  Future<void> _simulatePurchase(double score, String itemName) async {
    setState(() => _loading = true);
    
    try {
      await _leaderboardService.awardPointsForPurchase(score);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Purchased "$itemName" (Score: ${score.toStringAsFixed(0)})'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _viewRecommendations(String productName, String category, double score) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          productName: productName,
          category: category,
          score: score,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo: Test Features'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Testing Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap any product below to:\n'
                    '• Add points to your leaderboard\n'
                    '• View AI recommendations\n\n'
                    'Then check the Leaderboard tab!',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Sustainable Products 🌱',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          
          _ProductCard(
            name: 'Organic Avocados',
            category: 'Food & Grocery',
            score: 85,
            icon: Icons.local_florist,
            color: Colors.green,
            onPurchase: () => _simulatePurchase(85, 'Organic Avocados'),
            onViewDetails: () => _viewRecommendations('Organic Avocados', 'Food & Grocery', 85),
          ),
          
          _ProductCard(
            name: 'Bamboo Toothbrush',
            category: 'Personal Care',
            score: 92,
            icon: Icons.eco,
            color: Colors.teal,
            onPurchase: () => _simulatePurchase(92, 'Bamboo Toothbrush'),
            onViewDetails: () => _viewRecommendations('Bamboo Toothbrush', 'Personal Care', 92),
          ),
          
          _ProductCard(
            name: 'Reusable Water Bottle',
            category: 'Household',
            score: 95,
            icon: Icons.water_drop,
            color: Colors.blue,
            onPurchase: () => _simulatePurchase(95, 'Reusable Water Bottle'),
            onViewDetails: () => _viewRecommendations('Reusable Water Bottle', 'Household', 95),
          ),
          
          const SizedBox(height: 16),
          Text(
            'Less Sustainable Products ⚠️',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          
          _ProductCard(
            name: 'Plastic Water Bottles (24-pack)',
            category: 'Household',
            score: 35,
            icon: Icons.warning,
            color: Colors.orange,
            onPurchase: () => _simulatePurchase(35, 'Plastic Water Bottles'),
            onViewDetails: () => _viewRecommendations('Plastic Water Bottles (24-pack)', 'Household', 35),
          ),
          
          _ProductCard(
            name: 'Conventional Strawberries',
            category: 'Food & Grocery',
            score: 45,
            icon: Icons.report_problem,
            color: Colors.red,
            onPurchase: () => _simulatePurchase(45, 'Conventional Strawberries'),
            onViewDetails: () => _viewRecommendations('Conventional Strawberries', 'Food & Grocery', 45),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String category;
  final double score;
  final IconData icon;
  final Color color;
  final VoidCallback onPurchase;
  final VoidCallback onViewDetails;

  const _ProductCard({
    required this.name,
    required this.category,
    required this.score,
    required this.icon,
    required this.color,
    required this.onPurchase,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Score: ', style: TextStyle(fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    score.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'purchase') {
              onPurchase();
            } else if (value == 'details') {
              onViewDetails();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'purchase',
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, size: 20),
                  SizedBox(width: 8),
                  Text('Purchase & Earn Points'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 20),
                  SizedBox(width: 8),
                  Text('View Recommendations'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
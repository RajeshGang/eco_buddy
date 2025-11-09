import 'package:flutter/material.dart';
import '../catalog/leaderboard_service.dart';
import '../catalog/scoring_service.dart';
import 'receipt_parser.dart';
import 'scan_result_screen.dart';
import 'receipt_history_service.dart';

/// Screen to display parsed receipt items with scores
class ReceiptResultsScreen extends StatefulWidget {
  final List<ReceiptItem> items;
  final String rawText;
  final bool isFromHistory; // Flag to prevent re-saving when viewing from history

  const ReceiptResultsScreen({
    super.key,
    required this.items,
    required this.rawText,
    this.isFromHistory = false, // Default to false for new scans
  });

  @override
  State<ReceiptResultsScreen> createState() => _ReceiptResultsScreenState();
}

class _ReceiptResultsScreenState extends State<ReceiptResultsScreen> {
  final _scoringService = ScoringService();
  final _leaderboardService = LeaderboardService();
  final _historyService = ReceiptHistoryService();
  bool _processing = false;
  bool _pointsAwarded = false;
  Map<int, double> _itemScores = {};
  double? _overallScore;

  @override
  void initState() {
    super.initState();
    _calculateScores();
  }

  Future<void> _calculateScores() async {
    setState(() => _processing = true);

    try {
      final scores = <int, double>{};
      double totalScore = 0;

      for (var i = 0; i < widget.items.length; i++) {
        final item = widget.items[i];
        final category = ReceiptParser.categorizeItem(item.description);
        final baseScore = ReceiptParser.estimateScore(item.description, category);
        
        // Use scoring service for final score
        final score = await _scoringService.scoreItem(
          category: category,
          baseScore: baseScore,
        );
        
        scores[i] = score;
        totalScore += score;
      }

      final avgScore = widget.items.isEmpty ? 0.0 : totalScore / widget.items.length;

      if (mounted) {
        setState(() {
          _itemScores = scores;
          _overallScore = avgScore;
          _processing = false;
        });
        
        // Only award points and save if this is a new scan (not from history)
        if (!widget.isFromHistory) {
          await _awardPoints(avgScore);
          await _saveToHistory(avgScore);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating scores: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _awardPoints(double score) async {
    if (_pointsAwarded) return;
    
    try {
      await _leaderboardService.awardPointsForPurchase(score);
      if (mounted) {
        setState(() => _pointsAwarded = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Earned ${score.round()} points for this receipt!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error awarding points: $e');
    }
  }

  Future<void> _saveToHistory(double score) async {
    try {
      await _historyService.saveReceipt(
        items: widget.items,
        rawText: widget.rawText,
        overallScore: score,
      );
      debugPrint('Receipt saved to history');
    } catch (e) {
      debugPrint('Error saving receipt to history: $e');
    }
  }

  void _viewItemDetails(int index) {
    final item = widget.items[index];
    final score = _itemScores[index] ?? 50.0;
    final category = ReceiptParser.categorizeItem(item.description);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultScreen(
          productName: item.description,
          category: category,
          score: score,
          awardPoints: false, // Don't award points for individual items
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Analysis'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showRawText(),
            tooltip: 'View Raw Text',
          ),
        ],
      ),
      body: _processing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing receipt items...'),
                ],
              ),
            )
          : widget.items.isEmpty
              ? _buildEmptyState()
              : _buildItemsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Could not extract items from the receipt. Try taking a clearer photo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Try Again'),
            ),
            TextButton(
              onPressed: () => _showRawText(),
              child: const Text('View Raw Text'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: [
        // Overall Score Card
        if (_overallScore != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getScoreColor(_overallScore!),
                  _getScoreColor(_overallScore!).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Overall Sustainability Score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _overallScore!.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreDescription(_overallScore!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.items.length} items analyzed',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        // Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final score = _itemScores[index];
              final category = ReceiptParser.categorizeItem(item.description);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: score != null
                        ? _getScoreColor(score).withOpacity(0.2)
                        : Colors.grey[300],
                    child: score != null
                        ? Icon(
                            _getScoreIcon(score),
                            color: _getScoreColor(score),
                          )
                        : const Icon(Icons.hourglass_empty, color: Colors.grey),
                  ),
                  title: Text(
                    item.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Category: $category'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Qty: ${item.quantity}'),
                          const SizedBox(width: 16),
                          Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: score != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(score),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            score.toStringAsFixed(0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                  onTap: score != null ? () => _viewItemDetails(index) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRawText() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raw OCR Text'),
        content: SingleChildScrollView(
          child: Text(widget.rawText.isEmpty ? 'No text extracted' : widget.rawText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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

  IconData _getScoreIcon(double score) {
    if (score >= 75) return Icons.eco;
    if (score >= 50) return Icons.warning_amber;
    return Icons.error_outline;
  }

  String _getScoreDescription(double score) {
    if (score >= 90) return 'Excellent sustainable choices!';
    if (score >= 75) return 'Great job on sustainability!';
    if (score >= 50) return 'Room for improvement';
    return 'Consider more sustainable options';
  }
}

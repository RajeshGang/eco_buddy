import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'receipt_history_service.dart';
import 'receipt_results_screen.dart';

/// Screen to view receipt history
class ReceiptHistoryScreen extends StatelessWidget {
  const ReceiptHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyService = ReceiptHistoryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt History'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<ReceiptHistory>>(
        stream: historyService.getReceiptHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final receipts = snapshot.data ?? [];

          if (receipts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No receipts yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan a receipt to get started!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return _ReceiptCard(
                receipt: receipt,
                onTap: () => _viewReceipt(context, receipt),
                onDelete: () => _deleteReceipt(context, historyService, receipt),
              );
            },
          );
        },
      ),
    );
  }

  void _viewReceipt(BuildContext context, ReceiptHistory receipt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptResultsScreen(
          items: receipt.items,
          rawText: receipt.rawText,
          isFromHistory: true, // Prevent re-saving and re-awarding points
        ),
      ),
    );
  }

  Future<void> _deleteReceipt(
    BuildContext context,
    ReceiptHistoryService service,
    ReceiptHistory receipt,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Receipt?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.deleteReceipt(receipt.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting receipt: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _ReceiptCard extends StatelessWidget {
  final ReceiptHistory receipt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ReceiptCard({
    required this.receipt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y • h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Score badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getScoreColor(receipt.overallScore).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      receipt.overallScore.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(receipt.overallScore),
                      ),
                    ),
                    Text(
                      'score',
                      style: TextStyle(
                        fontSize: 10,
                        color: _getScoreColor(receipt.overallScore),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Receipt info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${receipt.itemCount} items',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(receipt.timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScoreDescription(receipt.overallScore),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getScoreColor(receipt.overallScore),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey[400],
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(double score) {
    if (score >= 75) return 'Excellent choices!';
    if (score >= 50) return 'Room for improvement';
    return 'Consider alternatives';
  }
}

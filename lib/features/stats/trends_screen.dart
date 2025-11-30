import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../scan/receipt_history_service.dart';
import '../scan/receipt_results_screen.dart';

enum TimePeriod { week, month, year }

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final _historyService = ReceiptHistoryService();
  TimePeriod _selectedPeriod = TimePeriod.month;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  DateTime _getStartDate(TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.week:
        return now.subtract(const Duration(days: 7));
      case TimePeriod.month:
        return now.subtract(const Duration(days: 30));
      case TimePeriod.year:
        return now.subtract(const Duration(days: 365));
    }
  }

  List<ReceiptHistory> _filterReceipts(List<ReceiptHistory> receipts) {
    final startDate = _getStartDate(_selectedPeriod);
    return receipts.where((r) => r.timestamp.isAfter(startDate)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  List<FlSpot> _buildChartData(List<ReceiptHistory> receipts) {
    if (receipts.isEmpty) return [];
    
    final filtered = _filterReceipts(receipts);
    if (filtered.isEmpty) return [];

    final spots = <FlSpot>[];
    for (int i = 0; i < filtered.length; i++) {
      spots.add(FlSpot(i.toDouble(), filtered[i].overallScore));
    }
    return spots;
  }

  String _getXAxisLabel(int index, List<ReceiptHistory> receipts) {
    final filtered = _filterReceipts(receipts);
    if (index >= filtered.length) return '';
    
    final date = filtered[index].timestamp;
    switch (_selectedPeriod) {
      case TimePeriod.week:
        return DateFormat('E').format(date); // Day of week
      case TimePeriod.month:
        return DateFormat('MMM d').format(date); // Month day
      case TimePeriod.year:
        return DateFormat('MMM').format(date); // Month
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Progress')),
        body: const Center(
          child: Text('Please sign in to view your progress'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: StreamBuilder<List<ReceiptHistory>>(
        stream: _historyService.getReceiptHistory(),
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

          final allReceipts = snapshot.data ?? [];
          final filteredReceipts = _filterReceipts(allReceipts);
          final chartData = _buildChartData(allReceipts);

          return CustomScrollView(
            slivers: [
              // Time period selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PeriodButton(
                        label: 'Week',
                        period: TimePeriod.week,
                        selected: _selectedPeriod == TimePeriod.week,
                        onTap: () => setState(() => _selectedPeriod = TimePeriod.week),
                      ),
                      const SizedBox(width: 8),
                      _PeriodButton(
                        label: 'Month',
                        period: TimePeriod.month,
                        selected: _selectedPeriod == TimePeriod.month,
                        onTap: () => setState(() => _selectedPeriod = TimePeriod.month),
                      ),
                      const SizedBox(width: 8),
                      _PeriodButton(
                        label: 'Year',
                        period: TimePeriod.year,
                        selected: _selectedPeriod == TimePeriod.year,
                        onTap: () => setState(() => _selectedPeriod = TimePeriod.year),
                      ),
                    ],
                  ),
                ),
              ),

              // Chart section
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score History',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (chartData.isEmpty)
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No data for selected period',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 250,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 25,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey[300]!,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: chartData.length > 7 ? 2 : 1,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 || index >= chartData.length) return const Text('');
                                        final label = _getXAxisLabel(index, allReceipts);
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: 25,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                minY: 0,
                                maxY: 100,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: chartData,
                                    isCurved: true,
                                    color: Colors.green,
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: Colors.green,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.green.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (filteredReceipts.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  label: 'Average',
                                  value: (filteredReceipts.map((r) => r.overallScore).reduce((a, b) => a + b) / filteredReceipts.length).toStringAsFixed(1),
                                ),
                                _StatItem(
                                  label: 'Best',
                                  value: filteredReceipts.map((r) => r.overallScore).reduce((a, b) => a > b ? a : b).toStringAsFixed(0),
                                ),
                                _StatItem(
                                  label: 'Total',
                                  value: filteredReceipts.length.toString(),
                                ),
                              ],
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
              ),

              // Receipt history section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Receipt History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (filteredReceipts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No receipts for selected period',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan a receipt to get started!',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final receipt = filteredReceipts[index];
                      return _ReceiptCard(
                        receipt: receipt,
                        onTap: () => _viewReceipt(context, receipt),
                      );
                    },
                    childCount: filteredReceipts.length,
                  ),
                ),
            ],
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
          isFromHistory: true,
        ),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final TimePeriod period;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.period,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final ReceiptHistory receipt;
  final VoidCallback onTap;

  const _ReceiptCard({
    required this.receipt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y • h:mm a');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              
              // Arrow icon
              Icon(Icons.chevron_right, color: Colors.grey[400]),
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

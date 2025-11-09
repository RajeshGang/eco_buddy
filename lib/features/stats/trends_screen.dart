import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendsScreen extends StatelessWidget {
  final String uid;
  const TrendsScreen({super.key, required this.uid});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('aggregates').doc('month').collection('all')
          .orderBy(FieldPath.fromString('__name__'))
          .snapshots(),
        builder: (c, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final points = <FlSpot>[]; int i = 0;
          for (final d in snap.data!.docs) {
            final v = (d['totalScore'] as num?)?.toDouble() ?? 0;
            points.add(FlSpot(i.toDouble(), v)); i++;
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(LineChartData(lineBarsData: [LineChartBarData(spots: points)])),
          );
        },
      ),
    );
  }
}

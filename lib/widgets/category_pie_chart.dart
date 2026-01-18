import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No expense data'));
    }

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    int index = 0;

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: data.entries.map((entry) {
            final color = colors[index++ % colors.length];
            return PieChartSectionData(
              value: entry.value,
              title: entry.key,
              color: color,
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

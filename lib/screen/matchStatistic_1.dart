import 'package:flutter/material.dart';

class StatisticPage extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const StatisticPage({required this.matchData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _buildStatisticsTable(matchData["statistics"]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTable(Map<String, dynamic> statistics) {
    if (statistics.isEmpty) {
      return Center(child: Text("No statistics available for this match."));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(1),
        },
        children: statistics.entries.map((entry) {
          return TableRow(
            children: [
              Text(
                entry.value["home"].toString(),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  entry.key,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                entry.value["away"].toString(),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

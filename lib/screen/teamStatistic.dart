import 'package:flutter/material.dart';

class TeamStatsTable extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const TeamStatsTable({Key? key, required this.statistics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) {
      return Center(
        child: Text(
          "No statistics available.",
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(1),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: statistics.entries.map((entry) {
        return TableRow(
          decoration: BoxDecoration(
            color: entry.key.contains("Goal")
                ? Colors.yellow.withOpacity(0.2)
                : Colors.transparent,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                entry.value["home"].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                entry.key,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                entry.value["away"].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

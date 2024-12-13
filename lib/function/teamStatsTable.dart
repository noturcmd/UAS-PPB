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
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Statistics"),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(1),
                  },
                  border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                  children: [
                    _buildTableHeader(),
                    ..._buildTableRows(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Home",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Statistic",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Away",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildTableRows() {
    return statistics.entries.map((entry) {
      final homeValue = entry.value["home"]?.toString() ?? "Not Available";
      final awayValue = entry.value["away"]?.toString() ?? "Not Available";

      return TableRow(
        decoration: BoxDecoration(
          color: entry.key.toLowerCase().contains("goal")
              ? Colors.yellow.withOpacity(0.2)
              : Colors.transparent,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              homeValue,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              entry.key,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              awayValue,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      );
    }).toList();
  }
}

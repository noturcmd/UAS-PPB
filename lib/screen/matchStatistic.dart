import 'package:flutter/material.dart';

class MatchStatisticScreen extends StatelessWidget {
  final Map<String, dynamic> matchData;
  final bool isFullStatistics;

  MatchStatisticScreen({
    required this.matchData,
    required this.isFullStatistics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${matchData["homeTeam"]} vs ${matchData["awayTeam"]}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMatchHeader(),
            _buildMenuBox(),
            SizedBox(height: 10.0),
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: isFullStatistics
                    ? _buildStatisticsTable(matchData['statistics'])
                    : _buildPartialStatistics(matchData['statistics']),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTeamColumn(matchData["homeTeam"], matchData["homeScore"]),
          Column(
            children: [
              Text(
                matchData["status"],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Stadium: ${matchData["stadium"]}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          _buildTeamColumn(matchData["awayTeam"], matchData["awayScore"]),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(String team, int score) {
    return Column(
      children: [
        Text(
          team,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Score: $score',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildMenuBox() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuButton('Match Summary'),
          _buildMenuButton('Lineups'),
          _buildMenuButton('Standing'),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title) {
    return ElevatedButton(
      onPressed: () {
        // Implement navigation logic or content toggle here
      },
      child: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
    );
  }

  Widget _buildStatisticsTable(Map<String, dynamic> statistics) {
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

  Widget _buildPartialStatistics(Map<String, dynamic> statistics) {
    final keysToShow = ['Shots Total', 'Ball Possession'];
    final filteredStats = statistics.entries
        .where((entry) => keysToShow.contains(entry.key))
        .toList();

    if (filteredStats.isEmpty) {
      return Center(
        child: Text(
          "No partial statistics available.",
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return _buildStatisticsTable(
        Map.fromEntries(filteredStats)); // Reuse the table method
  }
}

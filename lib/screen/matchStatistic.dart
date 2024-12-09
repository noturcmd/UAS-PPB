import 'package:flutter/material.dart';

class MatchStatisticScreen extends StatelessWidget {
  final Map<String, dynamic> matchData;
  final bool isFullStatistics;

  const MatchStatisticScreen({
    required this.matchData,
    required this.isFullStatistics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${matchData["homeTeam"]} vs ${matchData["awayTeam"]}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Match Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTeamInfo(
                    matchData["homeTeam"],
                    matchData["homeScore"],
                  ),
                  Text(
                    matchData["status"],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildTeamInfo(
                    matchData["awayTeam"],
                    matchData["awayScore"],
                  ),
                ],
              ),
            ),
            // Display Statistics
            if (matchData["statistics"] != null &&
                matchData["statistics"].isNotEmpty)
              _buildStatisticsTable(matchData["statistics"])
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isFullStatistics
                      ? "No statistics available for this match."
                      : "Statistics not available yet for this match.",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            // Referee and Stadium Information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Stadium: ${matchData["stadium"]}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(String team, int score) {
    return Column(
      children: [
        Text(
          team,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          score.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatisticsTable(Map<String, dynamic> statistics) {
    if (statistics.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "No statistics available for this match.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
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

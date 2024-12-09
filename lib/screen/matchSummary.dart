import 'package:flutter/material.dart';

class MatchSummaryPage extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const MatchSummaryPage({required this.matchData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Match Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home Team: ${matchData["homeTeam"]}', style: TextStyle(fontSize: 18)),
            Text('Away Team: ${matchData["awayTeam"]}', style: TextStyle(fontSize: 18)),
            Text('Score: ${matchData["homeScore"]} - ${matchData["awayScore"]}', style: TextStyle(fontSize: 18)),
            Text('Status: ${matchData["status"]}', style: TextStyle(fontSize: 18)),
            Text('Stadium: ${matchData["stadium"]}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

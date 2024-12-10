import 'package:flutter/material.dart';

class TeamSummary extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const TeamSummary({Key? key, required this.matchData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> events = matchData['events']; // Assuming 'events' is a list of events

    return Scaffold(
      appBar: AppBar(
        title: Text("Match Summary"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Teams: ${matchData['homeTeam']} vs ${matchData['awayTeam']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Score: ${matchData['homeScore']} - ${matchData['awayScore']}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Status: ${matchData['status']}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Stadium: ${matchData['stadium']}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Match Events:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...events.map((event) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${event['time']} ${event['type']} - ${event['player']} (${event['team']})",
                  style: TextStyle(fontSize: 16),
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

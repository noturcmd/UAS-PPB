import 'package:flutter/material.dart';

class StandingsPage extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const StandingsPage({required this.matchData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Standings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Standings are not available for this match."),
      ),
    );
  }
}

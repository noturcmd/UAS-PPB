import 'package:flutter/material.dart';

class LineupsPage extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const LineupsPage({required this.matchData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lineups')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Lineups are not available for this match."),
      ),
    );
  }
}

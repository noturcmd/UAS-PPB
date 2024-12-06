import 'package:flutter/material.dart';
import 'appDrawer.dart';

class ResultMatchesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result Matches'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Text('No match results available yet!'),
      ),
    );
  }
}

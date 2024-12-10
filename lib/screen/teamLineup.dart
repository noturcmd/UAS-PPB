import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeamLineup extends StatefulWidget {
  final int matchId;
  const TeamLineup({Key? key, required this.matchId}) : super(key: key);

  @override
  _TeamLineupState createState() => _TeamLineupState();
}

class _TeamLineupState extends State<TeamLineup> {
  Map<String, dynamic> lineupData = {};

  @override
  void initState() {
    super.initState();
    fetchLineupData();
  }

  Future<void> fetchLineupData() async {
    String apiUrl = 'https://apiv3.apifootball.com';
    String apiKey = '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192'; // Use your actual API key

    try {
      var response = await http.get(Uri.parse("$apiUrl/?action=get_lineups&match_id=${widget.matchId}&APIkey=$apiKey"));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.isNotEmpty) {
          setState(() {
            lineupData = data[data.keys.first]['lineup']; // Assuming 'data.keys.first' is the correct key
          });
        } else {
          print('Data parsed is not a Map or is empty.');
        }
      } else {
        print('Failed to fetch or invalid response: Status Code ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred while fetching or parsing data: $e');
      setState(() {
        // Set some state to show an error message or a retry button
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Lineup'),
      ),
      body: lineupData.isNotEmpty ? buildLineupList() : CircularProgressIndicator(),
    );
  }

  Widget buildLineupList() {
    List<Widget> homeStarters = [];
    List<Widget> awayStarters = [];

    var homePlayers = lineupData['home']['starting_lineups'] as List<dynamic>;
    var awayPlayers = lineupData['away']['starting_lineups'] as List<dynamic>;

    homeStarters = homePlayers.map<Widget>((player) => ListTile(
      title: Text(player['lineup_player']),
      trailing: Text('Shirt number: ${player['lineup_number'] ?? 'N/A'}'), // Handling null with a default value
    )).toList();

    awayStarters = awayPlayers.map<Widget>((player) => ListTile(
      title: Text(player['lineup_player']),
      trailing: Text('Shirt number: ${player['lineup_number'] ?? 'N/A'}'), // Handling null with a default value
    )).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          ExpansionTile(
            title: Text('Home Team'),
            children: homeStarters,
          ),
          ExpansionTile(
            title: Text('Away Team'),
            children: awayStarters,
          ),
        ],
      ),
    );
  }
}

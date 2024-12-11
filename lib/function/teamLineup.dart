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
    String apiKey = '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192'; // Use your real API key
    final url = "$apiUrl/?action=get_lineups&match_id=${widget.matchId}&APIkey=$apiKey";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data.containsKey(widget.matchId.toString())) {
          setState(() {
            lineupData = data[widget.matchId.toString()]['lineup'];
          });
        } else {
          print('Match ID not found in response');
        }
      } else {
        print('Failed to fetch lineup data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lineup data: $e');
      setState(() {
        lineupData = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Lineup Details'),
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: lineupData.isEmpty ? Center(child: CircularProgressIndicator()) : buildLineupList(),
    );
  }

  Widget buildLineupList() {
    var homeData = lineupData['home'] ?? {};
    var awayData = lineupData['away'] ?? {};

    Widget buildTeamList(Map<String, dynamic> teamData, String teamName) {
      List<Widget> playersWidgets = [];

      playersWidgets.add(
        ListTile(
          title: Text('$teamName Formation: ${teamData['formation'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.bold)),
        )
      );

      List<dynamic> starters = teamData['starting_lineups'] ?? [];
      playersWidgets.add(
        ExpansionTile(
          title: Text('Starting Lineup'),
          children: starters.map<Widget>((player) => ListTile(
            title: Text(player['lineup_player']),
            subtitle: Text('Number: ${player['lineup_number']} - Position: ${player['lineup_position']}'),
          )).toList(),
        )
      );

      List<dynamic> substitutes = teamData['substitutes'] ?? [];
      playersWidgets.add(
        ExpansionTile(
          title: Text('Substitutes'),
          children: substitutes.map<Widget>((player) => ListTile(
            title: Text(player['lineup_player']),
            subtitle: Text('Number: ${player['lineup_number']}'),
          )).toList(),
        )
      );

      List<dynamic> coaches = teamData['coach'] ?? [];
      if (coaches.isNotEmpty) {
        playersWidgets.add(
          ListTile(
            title: Text('Coach: ${coaches[0]['lineup_player']}'),
          )
        );
      }

      return Column(children: playersWidgets);
    }

    return ListView(
      children: [
        buildTeamList(homeData, "Home Team"),
        buildTeamList(awayData, "Away Team"),
      ],
    );
  }
}

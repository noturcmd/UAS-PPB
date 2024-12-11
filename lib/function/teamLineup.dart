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
  String homeTeamName = "Home Team";
  String awayTeamName = "Away Team";

  @override
  void initState() {
    super.initState();
    fetchLineupData();
  }

  Future<void> fetchLineupData() async {
    String apiUrl = 'https://apiv3.apifootball.com';
    String apiKey =
        '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192'; // Use your real API key
    final url =
        "$apiUrl/?action=get_lineups&match_id=${widget.matchId}&APIkey=$apiKey";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data.containsKey(widget.matchId.toString())) {
          final matchData = data[widget.matchId.toString()];
          setState(() {
            lineupData = matchData['lineup'] ?? {};
            homeTeamName = matchData['home_team'] ?? "Home Team";
            awayTeamName = matchData['away_team'] ?? "Away Team";
          });
        } else {
          print('Match ID not found in response');
        }
      } else {
        print(
            'Failed to fetch lineup data with status code: ${response.statusCode}');
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
        title: Text('Team Lineups'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: lineupData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(14.0),
              children: [
                _buildTeamCard(lineupData['home'] ?? {}, homeTeamName),
                _buildTeamCard(lineupData['away'] ?? {}, awayTeamName),
              ],
            ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> teamData, String teamName) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              teamName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            if (teamData['formation'] != null)
              Text(
                "Formation: ${teamData['formation']}",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            SizedBox(height: 10),
            _buildSection("Starting Lineup", teamData['starting_lineups'] ?? []),
            _buildSection("Substitutes", teamData['substitutes'] ?? []),
            _buildCoachSection(teamData['coach'] ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> players) {
    if (players.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "$title: No data available",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      children: players
          .map((player) => ListTile(
                title: Text(player['lineup_player'] ?? "Unknown Player"),
                subtitle: Text(
                  "Number: ${player['lineup_number'] ?? 'N/A'} - Position: ${player['lineup_position'] ?? 'N/A'}",
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCoachSection(List<dynamic> coaches) {
    if (coaches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Coach: No data available",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "Coach: ${coaches[0]['lineup_player'] ?? 'Unknown'}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

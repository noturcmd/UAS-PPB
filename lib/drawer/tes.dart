import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uas_ppb/function/teamLineup.dart';
import 'package:uas_ppb/function/teamStanding.dart';
import 'package:uas_ppb/function/teamStatsTable.dart';
import 'package:uas_ppb/function/teamSummary.dart';

class MatchStatisticScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;
  final bool isFullStatistics;

  MatchStatisticScreen({
    required this.matchData,
    required this.isFullStatistics,
  });

  @override
  _MatchStatisticScreenState createState() => _MatchStatisticScreenState();
}

class _MatchStatisticScreenState extends State<MatchStatisticScreen> {
  Widget? currentContent;
  String? homeLogoUrl;
  String? awayLogoUrl;

  @override
  void initState() {
    super.initState();
    _fetchLogos();
    currentContent = widget.isFullStatistics
        ? TeamStatsTable(statistics: widget.matchData['statistics'] ?? {})
        : Center(child: Text("Select an option from the menu"));
  }

  int getMatchId() {
    try {
      return int.parse(widget.matchData['matchId'].toString());
    } catch (e) {
      print('Error parsing match ID: $e');
      return -1; // Return a default or error code
    }
  }

  Future<void> _fetchLogos() async {
      const apiKey = '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192';  // Replace with your actual API key
      int leagueId = widget.matchData['leagueId'];
      var url = Uri.parse('https://apiv3.apifootball.com/?action=get_teams&league_id=$leagueId&APIkey=$apiKey');

      try {
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          print(data);  // Check the full API response structure
          var homeTeamData = data.firstWhere((team) => team['team_key'].toString() == widget.matchData['homeTeamId'], orElse: () => null);
          var awayTeamData = data.firstWhere((team) => team['team_key'].toString() == widget.matchData['awayTeamId'], orElse: () => null);

          if (homeTeamData != null && awayTeamData != null) {
            setState(() {
              homeLogoUrl = homeTeamData['team_badge'];
              awayLogoUrl = awayTeamData['team_badge'];
            });
          } else {
            print('Team data not found in API response');
          }
        } else {
          print('Failed to load data from API with status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching logos: $e');
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.matchData["homeTeam"]} vs ${widget.matchData["awayTeam"]}', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMatchHeader(),
          _buildMenuBox(),
          Expanded(child: currentContent ?? Center(child: Text("Please select an option from the menu"))),
        ],
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildTeamScoreColumn(widget.matchData["homeTeam"], widget.matchData["homeScore"], homeLogoUrl)),
              Text("vs", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              Expanded(child: _buildTeamScoreColumn(widget.matchData["awayTeam"], widget.matchData["awayScore"], awayLogoUrl)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Stadium: ${widget.matchData["stadium"]}', style: TextStyle(fontSize: 14, color: Colors.grey[700]), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  void updateContent(String title) {
    setState(() {
      switch (title) {
        case 'Match Summary':
          currentContent = TeamSummary(matchId: getMatchId());
          break;
        case 'Statistics':
          currentContent = TeamStatsTable(statistics: widget.matchData['statistics'] ?? {});
          break;
        case 'Lineups':
          int matchId = getMatchId();
          if (matchId != -1) {
            currentContent = TeamLineup(matchId: matchId);
          } else {
            currentContent = Center(child: Text("Invalid match ID"));
          }
          break;
        case 'Standings':
          currentContent = LeagueStandings(leagueId: int.tryParse(widget.matchData['leagueId'].toString()) ?? 0);
          break;
        default:
          currentContent = Center(child: Text("No data available for $title"));
          break;
      }
    });
  }

  Widget _buildTeamScoreColumn(String team, int score, String? logoUrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (logoUrl != null) 
        Image.network(
          logoUrl, 
          width: 50, 
          height: 50, 
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Text('😢');  // Indicates an error with loading the image
          },
        ),
        SizedBox(height: 8),
        Text(team, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        Text('Score: $score', style: TextStyle(fontSize: 16, color: Colors.grey[700]), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildMenuBox() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6.0, offset: Offset(0, 2))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['Match Summary', 'Lineups', 'Statistics', 'Standings'].map((title) => _buildMenuButton(title)).toList(),
      ),
    );
  }

  Widget _buildMenuButton(String title) {
    return ElevatedButton(
      onPressed: () => updateContent(title),
      child: Text(title, style: TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
    );
  }
}

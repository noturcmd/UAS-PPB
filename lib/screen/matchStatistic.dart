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
    final url = Uri.parse('https://apiv3.apifootball.com/?action=get_teams&league_id=${widget.matchData['leagueId']}&APIkey=$apiKey');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data);  // Check what the API returns
        setState(() {
          homeLogoUrl = _findTeamLogo(data, widget.matchData['homeTeam']);
          awayLogoUrl = _findTeamLogo(data, widget.matchData['awayTeam']);
        });
        print('Home Logo: $homeLogoUrl');  // See what URL is set for home
        print('Away Logo: $awayLogoUrl');  // See what URL is set for away
      } else {
        print('Failed to load team logos from API with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching team logos: $e');
    }
  }


  String? _findTeamLogo(List<dynamic> teams, String teamName) {
      print("Searching for logo of team: $teamName");
      for (var team in teams) {
          print("Checking team from API: ${team['team_name']}");
          if (team['team_name'].toString().toLowerCase() == teamName.toLowerCase()) {
              print("Match found. Badge URL: ${team['team_badge']}");
              return team['team_badge'];
          }
      }
      print("No match found for team: $teamName");
      return null;
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
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildTeamScoreColumn(widget.matchData["homeTeam"], widget.matchData["homeScore"], homeLogoUrl)),
                Text("vs", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Expanded(child: _buildTeamScoreColumn(widget.matchData["awayTeam"], widget.matchData["awayScore"], awayLogoUrl)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Stadium: ${widget.matchData["stadium"]}', style: TextStyle(fontSize: 16, color: Colors.grey[700]), textAlign: TextAlign.center),
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
              print('Failed to load image: $logoUrl');
              return Icon(Icons.broken_image);  // More explicit icon for loading failure
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
        margin: EdgeInsets.all(10), // Provides clear space around the container
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, // Neutral background color to emphasize buttons
          borderRadius: BorderRadius.circular(15), // Smoothly rounded corners
          boxShadow: [ // Subtle shadow for a raised effect
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: SingleChildScrollView( // Ensures the container can scroll horizontally if space is tight
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Match Summary', 'Lineups', 'Statistics', 'Standings']
                .map((title) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4), // Ensures space between buttons
                  child: _buildMenuButton(title),
                ))
                .toList(),
          ),
        ),
      );
  }

  Widget _buildMenuButton(String title) {
    return ElevatedButton(
      onPressed: () => updateContent(title),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade300, // Vibrant background color
        foregroundColor: Colors.white, // Text color for readability
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }

  //Sebelum diganti
  // Widget _buildMenuButton(String title) {
  //   return ElevatedButton(
  //     onPressed: () => updateContent(title),
  //     child: Text(title, style: TextStyle(fontSize: 16)),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.blueAccent, // button background color
  //       foregroundColor: Colors.white, // button text color
  //       elevation: 5, // button shadow elevation
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //     ),
  //   );
  // }

  // Widget _buildMenuButton(String title) {
  //   return ElevatedButton(
  //     onPressed: () => updateContent(title),
  //     child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.blue.shade300, // Button background color
  //       foregroundColor: Colors.white, // Button text color
  //       elevation: 4, // Shadow elevation
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //     ),
  //   );
  // }

}

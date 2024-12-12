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

  const MatchStatisticScreen({
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
    _fetchTeamBadges();
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

  Future<void> _fetchTeamBadges() async {
    const String apiUrl = 'https://apiv3.apifootball.com';
    const String apiKey = '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192';
    final leagueId = widget.matchData['leagueId'];

    if (leagueId == null) {
      print('League ID is null. Cannot fetch team badges.');
      return;
    }

    final url = Uri.parse('$apiUrl/?action=get_teams&league_id=$leagueId&APIkey=$apiKey');
    print('Fetching team badges from URL: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            homeLogoUrl = _findBadgeByTeamId(data, widget.matchData['homeTeamId']?.toString());
            awayLogoUrl = _findBadgeByTeamId(data, widget.matchData['awayTeamId']?.toString());
            print('Home Team Logo: $homeLogoUrl');
            print('Away Team Logo: $awayLogoUrl');
          });
        } else {
          print('Unexpected API response format: $data');
          _setDefaultLogos();
        }
      } else {
        print('API error with status code: ${response.statusCode}');
        _setDefaultLogos();
      }
    } catch (e) {
      print('Error fetching team badges: $e');
      _setDefaultLogos();
    }
  }

  void _setDefaultLogos() {
    setState(() {
      homeLogoUrl = 'assets/default_logo.png';
      awayLogoUrl = 'assets/default_logo.png';
    });
  }

  String? _findBadgeByTeamId(List<dynamic> teams, String? teamId) {
    if (teamId == null) {
      print('Team ID is null.');
      return 'assets/default_logo.png';
    }

    try {
      for (var team in teams) {
        print('Checking team: ${team['team_name']} with ID: ${team['team_key']}');
        if (team['team_key']?.toString() == teamId) {
          return team['team_badge'] ?? 'assets/default_logo.png';
        }
      }
    } catch (e) {
      print('Error finding badge for team ID $teamId: $e');
    }
    print('No badge found for team ID $teamId. Using default logo.');
    return 'assets/default_logo.png';
  }

  Widget _buildTeamLogo(String? logoUrl) {
    return logoUrl != null && logoUrl.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              logoUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $logoUrl');
                return Icon(Icons.broken_image, size: 50, color: Colors.grey);
              },
            ),
          )
        : Icon(Icons.flag_outlined, size: 50, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.matchData["homeTeam"]} vs ${widget.matchData["awayTeam"]}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              Expanded(
                child: _buildTeamScoreColumn(
                  widget.matchData["homeTeam"] ?? "Home",
                  widget.matchData["homeScore"] ?? 0,
                  homeLogoUrl,
                ),
              ),
              Text("vs",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              Expanded(
                child: _buildTeamScoreColumn(
                  widget.matchData["awayTeam"] ?? "Away",
                  widget.matchData["awayScore"] ?? 0,
                  awayLogoUrl,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Stadium: ${widget.matchData["stadium"] ?? "Unknown"}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScoreColumn(String team, int score, String? logoUrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTeamLogo(logoUrl),
        SizedBox(height: 8),
        Text(
          team,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          'Score: $score',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      ],
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
          currentContent = LeagueStandings(
              leagueId: int.tryParse(widget.matchData['leagueId']?.toString() ?? "0") ?? 0);
          break;
        default:
          currentContent = Center(child: Text("No data available for $title"));
          break;
      }
    });
  }

  Widget _buildMenuBox() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Match Summary', 'Lineups', 'Statistics', 'Standings']
              .map((title) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
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
        backgroundColor: Colors.blue.shade300,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }
}

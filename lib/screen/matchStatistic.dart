import 'package:flutter/material.dart';
import 'package:uas_ppb/function/teamLineup.dart';
import 'package:uas_ppb/function/teamStanding.dart';
import 'package:uas_ppb/function/teamStatsTable.dart';
import 'package:uas_ppb/function/teamSummary.dart'; // Make sure this import path is correct

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

  @override
  void initState() {
    super.initState();
    // Initialize the default view based on whether full statistics are enabled
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
          Expanded(
            child: currentContent ?? Center(child: Text("Please select an option from the menu")),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTeamColumn(widget.matchData["homeTeam"], widget.matchData["homeScore"]),
          Column(
            children: [
              Text(
                widget.matchData["status"],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Stadium: ${widget.matchData["stadium"]}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          _buildTeamColumn(widget.matchData["awayTeam"], widget.matchData["awayScore"]),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(String team, int score) {
    return Column(
      children: [
        Text(
          team,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Score: $score',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildMenuBox() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuButton('Match Summary'),
          _buildMenuButton('Lineups'),
          _buildMenuButton('Statistics'),
          _buildMenuButton('Standings'),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title) {
    return ElevatedButton(
      onPressed: () => updateContent(title),
      child: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
    );
  }
}

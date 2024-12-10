import 'package:flutter/material.dart';
import 'package:uas_ppb/screen/teamLineup.dart';
import 'package:uas_ppb/screen/teamStatistic.dart'; // Ensure this is the correct path
import 'package:uas_ppb/screen/teamSummary.dart'; // Ensure this is the correct path

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
    // Set default content
    currentContent = widget.isFullStatistics ? TeamStatsTable(statistics: widget.matchData['statistics']) : Text("Select an option from the menu");
  }

  int getMatchId() {
    try {
      if (widget.matchData.containsKey('matchId') && widget.matchData['matchId'] != null) {
        return int.parse(widget.matchData['matchId'].toString());
      } else {
        throw Exception("Match ID not found or invalid");
      }
    } catch (e) {
      print('Error parsing match ID: $e');
      return -1; // Return a default or error code
    }
  }

  void updateContent(String title) {
    Widget newContent;
    switch (title) {
      case 'Match Summary':
        newContent = TeamSummary(matchData: widget.matchData);
        break;
      case 'Statistics':
        newContent = TeamStatsTable(statistics: widget.matchData['statistics']);
        break;
      case 'Lineups':
        int matchId = getMatchId();
        if (matchId != -1) {
          newContent = TeamLineup(matchId: matchId);
        } else {
          newContent = Text("Invalid match ID");
        }
        break;
      default:
        newContent = Text("No data available for $title");
        break;
    }

    if (currentContent != newContent) {
      setState(() {
        currentContent = newContent;
      });
    }
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMatchHeader(),
            _buildMenuBox(),
            SizedBox(height: 10.0),
            currentContent ?? Center(child: Text("Please select an option from the menu")),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
          _buildMenuButton('Standing'),
          _buildMenuButton('Statistics'),
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

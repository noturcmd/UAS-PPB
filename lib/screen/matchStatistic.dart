import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    currentContent = widget.isFullStatistics
        ? TeamStatsTable(statistics: widget.matchData['statistics'] ?? {})
        : Center(child: Text("Select an option from the menu"));
  }

  int getMatchId() {
    try {
      print("Match Data: ${widget.matchData}");
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
    setState(() {
      switch (title) {
        case 'Match Summary':
          currentContent = TeamSummary(matchData: widget.matchData);
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMatchHeader(),
            _buildMenuBox(),
            SizedBox(height: 10.0),
            Container(
              width: double.infinity,
              child: currentContent ?? Center(child: Text("Please select an option from the menu")),
            ),
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

class TeamStatsTable extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const TeamStatsTable({Key? key, required this.statistics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) {
      return Center(
        child: Text(
          "No statistics available.",
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(1),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: statistics.entries.map((entry) {
        return TableRow(
          decoration: BoxDecoration(
            color: entry.key.contains("Goal")
                ? Colors.yellow.withOpacity(0.2)
                : Colors.transparent,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                entry.value["home"].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                entry.key,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                entry.value["away"].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

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
    String apiKey = 'your_api_key_here';  // Replace with your actual API key
    var response = await http.get(Uri.parse("$apiUrl/?action=get_lineups&match_id=${widget.matchId}&APIkey=$apiKey"));

    print("Fetching lineup data for match ID: ${widget.matchId}");

    if (response.statusCode == 200) {
      print("API Response: ${response.body}");
      var data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.isNotEmpty) {
        setState(() {
          // Use a safe check for dynamic keys
          String firstKey = data.keys.first;
          lineupData = data[firstKey]['lineup'] ?? {};
          print("Parsed Lineup Data: $lineupData");
        });
      } else {
        print("Error: Failed to fetch data. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        setState(() {
          lineupData = {};
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load lineup data. Please try again later.')),
        );
      }
    } else {
      print("Error: Failed to fetch data. Status code: ${response.statusCode}");
      throw Exception('Failed to load lineup data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Lineup'),
      ),
      body: lineupData.isNotEmpty
          ? buildLineupList()
          // : Center(child: CircularProgressIndicator(),),
          : Center(child: Text("No lineup data available"),),
          
    );
  }

  Widget buildLineupList() {
    if (lineupData.isEmpty) {
      return Center(child: Text("No lineup data available"));
    }

    List<dynamic> homePlayers = lineupData['home']?['starting_lineups'] ?? [];
    List<dynamic> awayPlayers = lineupData['away']?['starting_lineups'] ?? [];

    List<Widget> homeStarters = homePlayers.map((player) {
      return ListTile(
        title: Text(player['lineup_player'] ?? 'Unknown Player'),
        trailing: Text('Shirt number: ${player['lineup_number'] ?? 'N/A'}'),
      );
    }).toList();

    List<Widget> awayStarters = awayPlayers.map((player) {
      return ListTile(
        title: Text(player['lineup_player'] ?? 'Unknown Player'),
        trailing: Text('Shirt number: ${player['lineup_number'] ?? 'N/A'}'),
      );
    }).toList();

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

class TeamSummary extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const TeamSummary({Key? key, required this.matchData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> events = matchData['events'] ?? [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Teams: ${matchData['homeTeam']} vs ${matchData['awayTeam']}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Score: ${matchData['homeScore']} - ${matchData['awayScore']}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Status: ${matchData['status']}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Stadium: ${matchData['stadium']}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Match Events:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...events.map((event) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "${event['time']} ${event['type']} - ${event['player']} (${event['team']})",
                style: TextStyle(fontSize: 16),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}

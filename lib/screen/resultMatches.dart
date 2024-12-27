import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_ppb/function/timeConverter.dart';
import 'package:uas_ppb/screen/matchStatistic.dart';

class LeagueResultScreen extends StatefulWidget {
  final String leagueName;
  final String leagueId;

  const LeagueResultScreen({
    required this.leagueName,
    required this.leagueId,
  });

  @override
  _LeagueResultScreenState createState() => _LeagueResultScreenState();
}

class _LeagueResultScreenState extends State<LeagueResultScreen> {
  List<dynamic> allMatches = [];
  List<dynamic> filteredMatches = [];
  List<String> matchDates = [];
  String selectedDate = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeagueResults();
  }

  // Fetch match results for the selected league
  Future<void> fetchLeagueResults() async {
    const String apiUrl = "https://apiv3.apifootball.com";
    const String apiKey = "1a5b2d92cbb6a9b8a1b873068324468a40e6d73097ac24196d7ab886679269ff";

    DateTime now = DateTime.now();
    String weekAgo = now.subtract(Duration(days: 7)).toString().split(' ')[0];
    String today = "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}";

    final url = Uri.parse(
        '$apiUrl/?action=get_events&from=$weekAgo&to=$today&league_id=${widget.leagueId}&APIkey=$apiKey');
    print('Fetching league results from: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data is List) {
          setState(() {
            allMatches = data;
            matchDates = _extractUniqueMatchDates(data);
            if (matchDates.isNotEmpty) {
              selectedDate = matchDates[0]; // Default to the earliest match date
              filterMatchesByDate(selectedDate);
            }
            isLoading = false;
          });
        } else {
          print('Unexpected response format: $data');
          setState(() => isLoading = false);
        }
      } else {
        throw Exception('Failed to load results. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching results: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching results: $e')),
      );
    }
  }

  String _formatJakartaTime(String matchDate, String matchTime) {
    try {
      DateTime jakartaTime = convertToJakartaTime(matchDate, matchTime);
      return '${jakartaTime.toLocal().hour.toString().padLeft(2, '0')}:${jakartaTime.toLocal().minute.toString().padLeft(2, '0')} WIB';
    } catch (e) {
      print('Error converting time: $e');
      return 'Invalid Time';
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  List<String> _extractUniqueMatchDates(List<dynamic> matches) {
    final dates = matches.map<String>((match) => match['match_date'] as String).toSet().toList();
    dates.sort((a, b) => b.compareTo(a)); // Sort in descending order
    return dates;
  }

  void filterMatchesByDate(String date) {
    setState(() {
      filteredMatches = allMatches.where((match) => match['match_date'] == date).toList();
    });
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await fetchLeagueResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.leagueName} Results'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date selector
                if (matchDates.isNotEmpty)
                  Container(
                    height: 60,
                    color: Colors.grey[200],
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: matchDates.length,
                      itemBuilder: (context, index) {
                        String date = matchDates[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                              filterMatchesByDate(date);
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: selectedDate == date ? Colors.blue : Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Text(
                                index == 0 ? 'Today' : date.split('-').reversed.join('.'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Match list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: filteredMatches.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No matches available.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24, // Larger font size
                                    fontWeight: FontWeight.bold, // Bold text
                                    color: Colors.black54, // Optional color for visibility
                                  ),
                                ), // Space between the two texts
                                Text(
                                  '"' + widget.leagueName + '"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20, // Slightly smaller font size for the league name
                                    fontWeight: FontWeight.w500, // Medium weight for distinction
                                    color: Colors.black45, // Subtle color for differentiation
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredMatches.length,
                            itemBuilder: (context, index) {
                              var match = filteredMatches[index];

                              return GestureDetector(
                                onTap: () => _navigateToMatchStatistics(match),
                                child: Card(
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (match['team_home_badge'] != null &&
                                            match['team_home_badge'].isNotEmpty)
                                          Image.network(match['team_home_badge'], width: 30),
                                        SizedBox(width: 10),
                                        if (match['team_away_badge'] != null &&
                                            match['team_away_badge'].isNotEmpty)
                                          Image.network(match['team_away_badge'], width: 30),
                                      ],
                                    ),
                                    title: Text(
                                      '${match['match_hometeam_name']} vs ${match['match_awayteam_name']}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (match['match_date'] != null && match['match_time'] != null)
                                          Text(
                                            'Kick-off: ${_formatJakartaTime(match['match_date'], match['match_time'])}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        Text('Stadium: ${match['match_stadium'] ?? "Unknown"}'),
                                        Text('Status: ${match['match_status'] ?? "Finished"}'),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  void _navigateToMatchStatistics(dynamic match) async {
    final String apiUrl = "https://apiv3.apifootball.com";
    const String apiKey = "1a5b2d92cbb6a9b8a1b873068324468a40e6d73097ac24196d7ab886679269ff";
    final matchId = match['match_id'];

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final url = Uri.parse('$apiUrl/?action=get_statistics&match_id=$matchId&APIkey=$apiKey');
      final response = await http.get(url);

      Navigator.pop(context); // Close the loading dialog

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final statisticsData = data[matchId.toString()]?['statistics'] ?? [];

        final Map<String, dynamic> formattedStatistics = {};
        for (var stat in statisticsData) {
          if (stat is Map<String, dynamic> &&
              stat.containsKey('type') &&
              stat.containsKey('home') &&
              stat.containsKey('away')) {
            formattedStatistics[stat['type']] = {
              "home": stat['home'] ?? "0",
              "away": stat['away'] ?? "0",
            };
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchStatisticScreen(
              matchData: {
                "homeTeam": match['match_hometeam_name'] ?? "Unknown",
                "awayTeam": match['match_awayteam_name'] ?? "Unknown",
                "homeScore": int.tryParse(match['match_hometeam_score'] ?? "0") ?? 0,
                "awayScore": int.tryParse(match['match_awayteam_score'] ?? "0") ?? 0,
                "status": match['match_status'] ?? 'Finished',
                "stadium": match['match_stadium'] ?? 'Unknown',
                "statistics": formattedStatistics,
                "matchId": match['match_id'],
                "leagueId": widget.leagueId,
              },
              isFullStatistics: true,
            ),
          ),
        );
      } else {
        throw Exception('Failed to load statistics. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog if an error occurs
      print('Error fetching statistics: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching statistics: $e')),
      );
    }
  }
}

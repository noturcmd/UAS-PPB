import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_ppb/function/timeConverter.dart';
import 'package:uas_ppb/screen/matchStatistic.dart';

class LeagueMatchesScreen extends StatefulWidget {
  final String leagueName;
  final String leagueId;

  const LeagueMatchesScreen({
    required this.leagueName,
    required this.leagueId,
  });

  @override
  _LeagueMatchesScreenState createState() => _LeagueMatchesScreenState();
}

class _LeagueMatchesScreenState extends State<LeagueMatchesScreen> {
  List<dynamic> allMatches = [];
  List<dynamic> filteredMatches = [];
  List<String> matchDates = [];
  String selectedDate = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeagueMatches();
  }

  // Fetch matches for the selected league
  Future<void> fetchLeagueMatches() async {
    const String apiUrl = "https://apiv3.apifootball.com";
    const String apiKey = "5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192";

    DateTime now = DateTime.now();
    String today = "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}";
    String nextWeek = _getNextWeekDate();

    final url = Uri.parse(
        '$apiUrl/?action=get_events&from=$today&to=$nextWeek&league_id=${widget.leagueId}&APIkey=$apiKey');
    print('Fetching matches from: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data is List) {
          setState(() {
            allMatches = data;
            matchDates = _extractUniqueMatchDates(data);
            if (matchDates.isNotEmpty) {
              selectedDate = matchDates[0];
              filterMatchesByDate(selectedDate);
            }
            isLoading = false;
          });
        } else {
          print('Unexpected response format: $data');
          setState(() => isLoading = false);
        }
      } else {
        throw Exception('Failed to load matches. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching matches: $e')),
      );
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _getNextWeekDate() {
    DateTime nextWeek = DateTime.now().add(Duration(days: 7));
    return "${nextWeek.year}-${_twoDigits(nextWeek.month)}-${_twoDigits(nextWeek.day)}";
  }

  List<String> _extractUniqueMatchDates(List<dynamic> matches) {
    final dates = matches.map<String>((match) => match['match_date'] as String).toSet().toList();
    dates.sort();
    return dates;
  }

  void filterMatchesByDate(String date) {
    setState(() {
      filteredMatches = allMatches.where((match) => match['match_date'] == date).toList();
    });
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await fetchLeagueMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.leagueName} Matches'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date filter bar
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
                              DateTime jakartaTime =
                                  convertToJakartaTime(match['match_date'], match['match_time']);

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MatchStatisticScreen(
                                        matchData: {
                                          "homeTeam": match['match_hometeam_name'] ?? "Unknown",
                                          "awayTeam": match['match_awayteam_name'] ?? "Unknown",
                                          "homeScore": int.tryParse(match['match_hometeam_score'] ?? "0") ?? 0,
                                          "awayScore": int.tryParse(match['match_awayteam_score'] ?? "0") ?? 0,
                                          "status": match['match_status'] ?? 'Upcoming',
                                          "stadium": match['match_stadium'] ?? 'Unknown',
                                          "statistics": match['statistics'] ?? {},                                       
                                          "matchId": match['match_id'], // Pass match ID
                                          "leagueId": widget.leagueId,  // Pass league ID
                                        },
                                        isFullStatistics: false,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (match['team_home_badge'] != null &&
                                            match['team_home_badge'].isNotEmpty)
                                          Image.network(match['team_home_badge'], width: 30)
                                        else
                                          Text('No logo'),
                                        SizedBox(width: 10),
                                        if (match['team_away_badge'] != null &&
                                            match['team_away_badge'].isNotEmpty)
                                          Image.network(match['team_away_badge'], width: 30)
                                        else
                                          Text('No logo'),
                                      ],
                                    ),
                                    title: Text(
                                      '${match['match_hometeam_name']} vs ${match['match_awayteam_name']}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Date: ${jakartaTime.toLocal().toIso8601String().split('T')[0]}'),
                                        Text('Time: ${jakartaTime.hour.toString().padLeft(2, '0')}:${jakartaTime.minute.toString().padLeft(2, '0')} WIB'),
                                        Text('Stadium: ${match['match_stadium'] ?? "Unknown"}'),
                                        Text('Status: ${match['match_status']}'),
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
}

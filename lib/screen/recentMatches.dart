import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  List<String> dates = [];
  String selectedDate = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    generateDates();
    fetchLeagueMatches();
  }

  // Generate a list of dates (e.g., today and next 6 days)
  void generateDates() {
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      dates.add("${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}");
    }
    selectedDate = dates[0]; // Default to the current day
  }

  // Fetch matches and filter them based on the selected date
  Future<void> fetchLeagueMatches() async {
    const String apiUrl = "https://apiv3.apifootball.com";
    const String apiKey = "5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192"; // Replace with your actual API key

    final url = Uri.parse(
        '$apiUrl/?action=get_events&from=${dates[0]}&to=${dates.last}&league_id=${widget.leagueId}&APIkey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        allMatches = data;
        filterMatchesByDate(selectedDate);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.reasonPhrase}')),
      );
    }
  }

  // Filter matches based on the selected date
  void filterMatchesByDate(String date) {
    setState(() {
      filteredMatches = allMatches.where((match) => match['match_date'] == date).toList();
    });
  }

  // Helper to format two digits
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Refresh data
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchLeagueMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.leagueName} Matches'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date selector
                Container(
                  height: 60,
                  color: Colors.grey[200],
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      String date = dates[index];
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
                              index == 0 ? 'Current Day' : date.split('-').reversed.join('.'),
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
                            child: Text(
                              'No matches available for $selectedDate.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredMatches.length,
                            itemBuilder: (context, index) {
                              var match = filteredMatches[index];
                              return Card(
                                margin: EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(
                                    '${match['match_hometeam_name']} vs ${match['match_awayteam_name']}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Date: ${match['match_date']} ${match['match_time']}'),
                                      Text('Status: ${match['match_status']}'),
                                      Text(
                                          'Score: ${match['match_hometeam_score']} - ${match['match_awayteam_score']}'),
                                    ],
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

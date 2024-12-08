import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future<void> fetchLeagueResults() async {
    const String apiUrl = "https://apiv3.apifootball.com";
    const String apiKey =
        "5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192"; // Replace with your actual API key

    DateTime now = DateTime.now();
    String weekAgo = now.subtract(Duration(days: 7)).toString().split(' ')[0];
    String today = "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}";

    final url = Uri.parse(
        '$apiUrl/?action=get_events&from=$weekAgo&to=$today&league_id=${widget.leagueId}&APIkey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
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
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.reasonPhrase}')),
      );
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  List<String> _extractUniqueMatchDates(List<dynamic> matches) {
    final dates = matches.map<String>((match) => match['match_date'] as String).toSet().toList();
    dates.sort((a, b) => b.compareTo(a)); // Sort in descending order for past matches
    return dates;
  }

  void filterMatchesByDate(String date) {
    DateTime now = DateTime.now();
    setState(() {
      filteredMatches = allMatches.where((match) {
        DateTime matchDateTime = DateTime.parse(
            '${match['match_date']} ${match['match_time']}');
        return match['match_date'] == date && matchDateTime.isBefore(now);
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchLeagueResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              'No results available for $selectedDate.',
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

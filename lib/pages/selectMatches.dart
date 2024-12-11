import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../drawer/appDrawer.dart';
import '../screen/recentMatches.dart'; // For recent matches
import '../screen/resultMatches.dart'; // For result matches

class SelectMatchesScreen extends StatefulWidget {
  final String matchType; // Either 'recent' or 'result'

  SelectMatchesScreen({required this.matchType});

  @override
  _SelectMatchesScreenState createState() => _SelectMatchesScreenState();
}

class _SelectMatchesScreenState extends State<SelectMatchesScreen> {
  List<dynamic> leagues = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeagues();
  }

  Future<void> fetchLeagues() async {
    const String apiUrl = 'https://apiv3.apifootball.com';
    const String apiKey = '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192';
    final url = Uri.parse('$apiUrl/?action=get_leagues&APIkey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          leagues = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load leagues');
      }
    } catch (e) {
      print('Error fetching leagues: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matchType == 'recent'
            ? 'Select League for Recent Matches'
            : 'Select League for Result Matches'),
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: leagues.length,
                itemBuilder: (context, index) {
                  final league = leagues[index];
                  return GestureDetector(
                    onTap: () {
                      if (widget.matchType == 'recent') {
                        // Navigate to Recent Matches page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeagueMatchesScreen(
                              leagueName: league['league_name'] ?? 'Unknown League',
                              leagueId: league['league_id'].toString(),
                            ),
                          ),
                        );
                      } else if (widget.matchType == 'result') {
                        // Navigate to Result Matches page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeagueResultScreen(
                              leagueName: league['league_name'] ?? 'Unknown League',
                              leagueId: league['league_id'].toString(),
                            ),
                          ),
                        );
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: league['league_logo'] != null
                                  ? Image.network(
                                      league['league_logo'],
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image_not_supported),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              league['league_name'] ?? 'Unknown League',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
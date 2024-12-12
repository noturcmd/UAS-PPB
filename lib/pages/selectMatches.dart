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
  Map<String, List<dynamic>> countriesWithLeagues = {};
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
        Map<String, List<dynamic>> groupedLeagues = {};

        for (var league in data) {
          String country = league['country_name'] ?? 'Unknown Country';
          if (!groupedLeagues.containsKey(country)) {
            groupedLeagues[country] = [];
          }
          groupedLeagues[country]?.add(league);
        }

        setState(() {
          countriesWithLeagues = Map.fromEntries(
            groupedLeagues.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
          );
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
            ? 'Select League for Upcoming Matches'
            : 'Select League for Result Matches'),
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: countriesWithLeagues.entries.map((entry) {
                  String country = entry.key;
                  List<dynamic> leagues = entry.value;
                  String? countryLogo = leagues.isNotEmpty ? leagues[0]['country_logo'] : null;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ExpansionTile(
                      leading: countryLogo != null && countryLogo.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                countryLogo,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.flag_outlined, size: 40, color: Colors.grey);
                                },
                              ),
                            )
                          : Icon(Icons.flag_outlined, size: 50, color: Colors.grey),
                      title: Text(
                        country,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: leagues.map((league) {
                        return ListTile(
                          leading: (league['league_logo'] != null && league['league_logo'].isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    league['league_logo'],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Text(
                                        "No Logo",
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  "No Logo",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                          title: Text(
                            league['league_name'] ?? 'Unknown League',
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            if (widget.matchType == 'recent') {
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
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
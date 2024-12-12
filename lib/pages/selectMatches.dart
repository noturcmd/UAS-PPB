import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../drawer/appDrawer.dart';
import '../screen/recentMatches.dart'; // For recent matches
import '../screen/resultMatches.dart'; // For result matches

class SelectMatchesScreen extends StatefulWidget {
  final String matchType; // Either 'recent' or 'result'

  const SelectMatchesScreen({required this.matchType});

  @override
  _SelectMatchesScreenState createState() => _SelectMatchesScreenState();
}

class _SelectMatchesScreenState extends State<SelectMatchesScreen> {
  Map<String, List<dynamic>> countriesWithLeagues = {};
  bool isLoading = true;
  String searchQuery = ""; // Holds the search query

  @override
  void initState() {
    super.initState();
    fetchLeagues();
  }

  // Fetch leagues grouped by countries
  Future<void> fetchLeagues() async {
    const String apiUrl = 'https://apiv3.apifootball.com';
    const String apiKey = '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192';
    final url = Uri.parse('$apiUrl/?action=get_leagues&APIkey=$apiKey');
    print('Fetching leagues from: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          // Group leagues by country
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
          print('Unexpected response format: $data');
          setState(() => isLoading = false);
        }
      } else {
        throw Exception('Failed to load leagues. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching leagues: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching leagues: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[800], // Change this to your desired color'
          iconTheme: IconThemeData(
            color: Colors.white, // Change the color of the drawer (hamburger) icon
          ),
        title: Text(
          widget.matchType == 'recent'
              ? 'League for Upcoming Matches'
              : 'League for Result Matches',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Change text color to white
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search the countries...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
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

                  // Filter leagues and countries based on the search query
                  if (searchQuery.isNotEmpty &&
                      !country.toLowerCase().contains(searchQuery) &&
                      !leagues.any((league) => (league['league_name'] ?? '').toLowerCase().contains(searchQuery))) {
                    return SizedBox.shrink(); // Skip items that don't match the search
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // More rounded corners
                    ),
                    child: ExpansionTile(
                      leading: _buildCountryLogo(countryLogo),
                      title: Text(
                        country,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey, // Improved text color
                        ),
                      ),
                      children: leagues.map((league) {
                        return ListTile(
                          leading: _buildLeagueLogo(league['league_logo']),
                          title: Text(
                            league['league_name'] ?? 'Unknown League',
                            style: TextStyle(fontSize: 16, color: Colors.grey[800]), // Consistent style
                          ),
                          onTap: () => _navigateToMatches(league),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  // Build country logo widget
  Widget _buildCountryLogo(String? logoUrl) {
    return logoUrl != null && logoUrl.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              logoUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.flag_outlined, size: 40, color: Colors.grey);
              },
            ),
          )
        : Icon(Icons.flag_outlined, size: 50, color: Colors.grey);
  }

  // Build league logo widget
  Widget _buildLeagueLogo(String? logoUrl) {
    return logoUrl != null && logoUrl.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              logoUrl,
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
          );
  }

  // Navigate to matches based on match type
  void _navigateToMatches(dynamic league) {
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
  }
}

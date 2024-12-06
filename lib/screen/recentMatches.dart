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
  List<dynamic> matches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeagueMatches();
  }

  Future<void> fetchLeagueMatches() async {
    const String apiUrl = "https://apiv3.apifootball.com";
    const String apiKey = "5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192"; // Replace with your actual API key
    final url = Uri.parse(
        '$apiUrl/?action=get_events&from=2024-12-01&to=2024-12-07&league_id=${widget.leagueId}&APIkey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        matches = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.leagueName} Matches'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : matches.isEmpty
              ? Center(
                  child: Text(
                    'No matches available for ${widget.leagueName}.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    var match = matches[index];
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
                            Text('Date: ${match['match_date']} ${match['match_time']}'),
                            Text('Status: ${match['match_status']}'),
                            Text(
                                'Score: ${match['match_hometeam_score']} - ${match['match_awayteam_score']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

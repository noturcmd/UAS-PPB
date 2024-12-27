import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeagueStandings extends StatefulWidget {
  final int leagueId;

  LeagueStandings({Key? key, required this.leagueId}) : super(key: key);

  @override
  _LeagueStandingsState createState() => _LeagueStandingsState();
}

class _LeagueStandingsState extends State<LeagueStandings> {
  List<dynamic> standings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStandings();
  }

  Future<void> fetchStandings() async {
    String apiUrl = 'https://apiv3.apifootball.com';
    String apiKey = '1a5b2d92cbb6a9b8a1b873068324468a40e6d73097ac24196d7ab886679269ff';
    final url = "$apiUrl/?action=get_standings&league_id=${widget.leagueId}&APIkey=$apiKey";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          standings = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load standings');
      }
    } catch (e) {
      print('Failed to load data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("League Standings"),
        automaticallyImplyLeading: false, // This will remove the back button
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: standings.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(standings[index]["team_badge"] ?? ""),
                              radius: 25,
                              backgroundColor: Colors.grey[200],
                            ),
                            title: Text(
                              standings[index]["team_name"] ?? "Unknown Team",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Position: ${standings[index]["overall_league_position"]} - Points: ${standings[index]["overall_league_PTS"]}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Played",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  standings[index]["overall_league_payed"]?.toString() ?? "0",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

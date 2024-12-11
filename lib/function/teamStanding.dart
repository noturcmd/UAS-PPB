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
    String apiKey = '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192';
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
          : ListView.builder(
              itemCount: standings.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(standings[index]["team_badge"]),
                  title: Text(standings[index]["team_name"]),
                  subtitle: Text("Position: ${standings[index]["overall_league_position"]} - Points: ${standings[index]["overall_league_PTS"]}"),
                  trailing: Text("Played: ${standings[index]["overall_league_payed"]}"),
                );
              },
            ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(FootballApp());
}

class FootballApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Matches',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MatchesTabScreen(),
    );
  }
}

class MatchesTabScreen extends StatefulWidget {
  @override
  _MatchesTabScreenState createState() => _MatchesTabScreenState();
}

class _MatchesTabScreenState extends State<MatchesTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Football Matches'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Premier League'),
            Tab(text: 'La Liga'),
            Tab(text: 'Serie A'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MatchesScreen(leagueId: 152), // Premier League
          MatchesScreen(leagueId: 302), // La Liga
          MatchesScreen(leagueId: 207), // Serie A
        ],
      ),
    );
  }
}

class MatchesScreen extends StatefulWidget {
  final int leagueId;

  MatchesScreen({required this.leagueId});

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<dynamic> matches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    const String apiUrl = "https://apiv3.apifootball.com";
    const String apiKey = "5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192"; // Replace with your actual API key
    final url = Uri.parse(
        '$apiUrl/?action=get_events&from=2024-12-06&to=2024-12-13&league_id=${widget.leagueId}&APIkey=$apiKey');
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
    return isLoading
        ? Center(child: CircularProgressIndicator())
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
          );
  }
}

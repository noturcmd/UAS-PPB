import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeamSummary extends StatefulWidget {
  final int matchId;

  const TeamSummary({Key? key, required this.matchId}) : super(key: key);

  @override
  _TeamSummaryState createState() => _TeamSummaryState();
}

class _TeamSummaryState extends State<TeamSummary> {
  Map<String, dynamic> matchDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatchDetails();
  }

  Future<void> fetchMatchDetails() async {
    String apiUrl = 'https://apiv3.apifootball.com';
    String apiKey = '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192'; // Replace with your actual API key
    final url = "$apiUrl/?action=get_events&match_id=${widget.matchId}&APIkey=$apiKey";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            matchDetails = data[0];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print("No data available or data is not in expected format");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to fetch data (status: ${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Exception while fetching match details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Match Summary"),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : matchDetails.isNotEmpty ? buildMatchDetails() : Center(child: Text("No Match Data Available")),
    );
  }

  Widget buildMatchDetails() {
    List<dynamic> goalscorers = matchDetails['goalscorer'] ?? [];
    List<dynamic> cards = matchDetails['cards'] ?? [];
    Map<String, dynamic> substitutions = matchDetails['substitutions'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildEventSection("1st Half", goalscorers, cards, substitutions['home'] ?? [], substitutions['away'] ?? [], true),
          buildEventSection("2nd Half", goalscorers, cards, substitutions['home'] ?? [], substitutions['away'] ?? [], false),
        ],
      ),
    );
  }

  Widget buildEventSection(String title, List<dynamic> goals, List<dynamic> cards, List<dynamic> homeSubs, List<dynamic> awaySubs, bool isFirstHalf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ...goals.where((g) => isFirstHalf ? g['time'].endsWith("1") : g['time'].endsWith("2")).map<Widget>((goal) => ListTile(
          title: Text("${goal['time']}' ${goal['home_scorer'] ?? goal['away_scorer']} (Goal)"),
          subtitle: Text("Assist: ${goal['home_assist'] ?? goal['away_assist']}"),
          leading: Icon(Icons.sports_soccer, color: Colors.green),
        )),
        ...cards.where((c) => isFirstHalf ? c['time'].endsWith("1") : c['time'].endsWith("2")).map<Widget>((card) => ListTile(
          title: Text("${card['time']}' ${card['home_fault'] ?? card['away_fault']} (Card)"),
          leading: Icon(Icons.warning, color: Colors.yellow),
        )),
        ...homeSubs.map<Widget>((sub) => ListTile(
          title: Text("${sub['time']}' ${sub['substitution']} (Sub)"),
          leading: Icon(Icons.sync, color: Colors.blue),
        )),
        ...awaySubs.map<Widget>((sub) => ListTile(
          title: Text("${sub['time']}' ${sub['substitution']} (Sub)"),
          leading: Icon(Icons.sync, color: Colors.blue),
        )),
      ],
    );
  }
}

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
          : matchDetails.isNotEmpty
              ? buildMatchDetails()
              : Center(child: Text("No Match Data Available")),
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
          buildEventSection("1st Half", goalscorers, cards, substitutions['home'] ?? [], substitutions['away'] ?? [], "1st Half"),
          SizedBox(height: 20),
          buildEventSection("2nd Half", goalscorers, cards, substitutions['home'] ?? [], substitutions['away'] ?? [], "2nd Half"),
        ],
      ),
    );
  }

  Widget buildEventSection(
    String title,
    List<dynamic> goalscorers,
    List<dynamic> cards,
    List<dynamic> homeSubs,
    List<dynamic> awaySubs,
    String halfPeriod,
  ) {
    List<Widget> eventWidgets = [
      Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    ];

    // Add goalscorers
    eventWidgets.addAll(
      goalscorers
          .where((goal) => goal['score_info_time'] == halfPeriod)
          .map<Widget>(
            (goal) => ListTile(
              leading: Icon(Icons.sports_soccer, color: Colors.green),
              title: Text(
                "${goal['time']}' ${goal['home_scorer']?.isNotEmpty == true ? goal['home_scorer'] : goal['away_scorer']} (Goal)",
              ),
              subtitle: Text(
                "Assist: ${goal['home_assist']?.isNotEmpty == true ? goal['home_assist'] : goal['away_assist'] ?? 'No assist'}",
              ),
            ),
          ),
    );

    // Add cards
    eventWidgets.addAll(
      cards
          .where((card) => card['score_info_time'] == halfPeriod)
          .map<Widget>(
            (card) => ListTile(
              leading: Icon(Icons.warning, color: card['card'] == 'yellow card' ? Colors.yellow : Colors.red),
              title: Text(
                "${card['time']}' ${card['home_fault']?.isNotEmpty == true ? card['home_fault'] : card['away_fault']} (${capitalize(card['card']?.replaceAll(' card', ''))})",
              ),
            ),
          ),
    );

    // Add home substitutions
    eventWidgets.addAll(
      homeSubs
          .map<Widget>(
            (sub) => ListTile(
              leading: Icon(Icons.sync, color: Colors.blue),
              title: Text("${sub['time']}' ${sub['substitution']} (Sub)"),
            ),
          ),
    );

    // Add away substitutions
    eventWidgets.addAll(
      awaySubs
          .map<Widget>(
            (sub) => ListTile(
              leading: Icon(Icons.sync, color: Colors.blue),
              title: Text("${sub['time']}' ${sub['substitution']} (Sub)"),
            ),
          ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: eventWidgets,
    );
  }

  String capitalize(String? input) {
    if (input == null || input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1);
  }
}

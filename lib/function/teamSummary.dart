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
    String apiKey = '5e213ecca1111bb3f2f67189e7a0e83e5d89ea41586b02afb2c713a3a16c6192';
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
        automaticallyImplyLeading: false, // This will remove the back button
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : matchDetails.isNotEmpty ? buildMatchDetails() : Center(child: Text("No Match Data Available")),
    );
  }

  Widget buildMatchDetails() {
    List<dynamic> goalscorers = matchDetails['goalscorer'] ?? [];
    String referee = matchDetails['match_referee'] ?? 'Unknown';
    String stadium = matchDetails['match_stadium'] ?? 'Unknown Stadium';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${matchDetails['match_hometeam_name']} vs ${matchDetails['match_awayteam_name']}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text("Score: ${matchDetails['match_hometeam_score']} - ${matchDetails['match_awayteam_score']}"),
          Text("Stadium: $stadium"),
          Text("Referee: $referee"),
          Divider(),
          Text("Goals:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...goalscorers.map<Widget>((goal) => ListTile(
            title: Text("${goal['time']}' ${goal['home_scorer'] ?? goal['away_scorer']}"),
            subtitle: Text("Assist: ${goal['home_assist'] ?? goal['away_assist']}"),
          )),
        ],
      ),
    );
  }
}

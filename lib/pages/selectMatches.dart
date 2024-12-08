import 'package:flutter/material.dart';
import '../drawer/appDrawer.dart';
import '../screen/recentMatches.dart'; // For recent matches
import '../screen/resultMatches.dart'; // For result matches

class SelectMatchesScreen extends StatelessWidget {
  final String matchType; // Either 'recent' or 'result'

  SelectMatchesScreen({required this.matchType});

  final List<Map<String, String>> leagues = [
    {
      "name": "Premier League",
      "image": "images/logo/Premier_League.jpeg",
      "leagueId": "152"
    },
    {
      "name": "Serie A",
      "image": "images/logo/Serie_A.jpeg",
      "leagueId": "207"
    },
    {
      "name": "La Liga",
      "image": "images/logo/LaLiga.jpeg",
      "leagueId": "302"
    },
    {
      "name": "Ligue 1",
      "image": "images/logo/Ligue_1.jpeg",
      "leagueId": "168"
    },
    {
      "name": "Eredivisie",
      "image": "images/logo/Eredivisie.jpeg",
      "leagueId": "244"
    },
    {
      "name": "Liga Portugal",
      "image": "images/logo/Liga_Portugal.jpeg",
      "leagueId": "266"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(matchType == 'recent' ? 'Select League for Recent Matches' : 'Select League for Result Matches'),
      ),
      drawer: AppDrawer(),
      body: Padding(
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
                if (matchType == 'recent') {
                  // Navigate to Recent Matches page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeagueMatchesScreen(
                        leagueName: league["name"]!,
                        leagueId: league["leagueId"]!,
                      ),
                    ),
                  );
                } else if (matchType == 'result') {
                  // Navigate to Result Matches page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeagueResultScreen(
                        leagueName: league["name"]!,
                        leagueId: league["leagueId"]!,
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
                        child: Image.asset(
                          league["image"]!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        league["name"]!,
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

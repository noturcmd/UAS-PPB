import 'package:flutter/material.dart';
import '../drawer/appDrawer.dart';
import '../screen/recentMatches.dart'; // Create a new page for individual league matches

class SelectMatchesScreen extends StatelessWidget {
  final List<Map<String, String>> leagues = [
    {
      "name": "Premier League",
      "image": "images/logo/Premier_League.jpeg", // Replace with your image paths
      "leagueId": "152"
    },
    {
      "name": "Serie A",
      "image": "images/logo/Serie_A.jpeg", // Replace with your image paths
      "leagueId": "207"
    },
    {
      "name": "La Liga",
      "image": "images/logo/LaLiga.jpeg", // Replace with your image paths
      "leagueId": "302"
    },
    {
      "name": "Ligue 1",
      "image": "images/logo/Ligue_1.jpeg", // Replace with your image paths
      "leagueId": "168"
    },
    {
      "name": "Eredivisie",
      "image": "images/logo/Eredivisie.jpeg", // Replace with your image paths
      "leagueId": "244"
    },
    {
      "name": "Liga Portugal",
      "image": "images/logo/Liga_Portugal.jpeg", // Replace with your image paths
      "leagueId": "266"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select League'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Display 2 blocks per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 2, // Adjust aspect ratio for block size
          ),
          itemCount: leagues.length,
          itemBuilder: (context, index) {
            final league = leagues[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeagueMatchesScreen(
                      leagueName: league["name"]!,
                      leagueId: league["leagueId"]!,
                    ),
                  ),
                );
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

import 'package:flutter/material.dart';
import 'package:uas_ppb/drawer/appDrawer.dart';
import 'pages/selectMatches.dart';
import 'pages/favoritesTeam.dart';
import 'screen/resultMatches.dart';

void main() {
  runApp(FootballApp());
}

class FootballApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // Make scaffold background transparent
      ),
      home: NavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Football Match App',
          style: TextStyle(
            color: const Color.fromRGBO(27, 31, 43, 1), // Change the text color here
          ),
        ),
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove shadow for a clean look
      ),
      drawer: AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background/home_bg.jpg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  SelectMatchesScreen(matchType: 'recent')),
                  );
                },
                child: Text('View Recent Matches'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritesScreen()),
                  );
                },
                child: Text('Favorites'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectMatchesScreen(matchType: 'result')),
                  );
                },
                child: Text('View Match Results'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:uas_ppb/main.dart';
import '../pages/selectMatches.dart';
import '../pages/favoritesTeam.dart';
import '../pages/login_page.dart';


class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Text(
              'Football Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle_sharp),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NavigationScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.sports_soccer),
            title: Text('Recent Matches'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SelectMatchesScreen(matchType: 'recent')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Result Matches'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SelectMatchesScreen(matchType: 'result')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Login/Register'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uas_ppb/main.dart';
import '../pages/selectMatches.dart';
import '../pages/favoritesTeam.dart';
import '../pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[800],
            ),
            padding: EdgeInsets.zero, // Remove internal padding
            child: Container(
              width: double.infinity, // Extend to fill the entire width

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                    'images/logo/soccer_hub.png', // Add your logo here
                    height: 300,
                    width: 300,
                  ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Soccer Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your Football Companion',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => NavigationScreen()),
                    );
                  },
                ),
                // _buildDrawerItem(
                //   icon: Icons.favorite,
                //   title: 'Favorites',
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (context) => FavoritesScreen()),
                //     );
                //   },
                // ),
                _buildDrawerItem(
                  icon: Icons.sports_soccer,
                  title: 'Upcoming Matches',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SelectMatchesScreen(matchType: 'recent')),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'Result Matches',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SelectMatchesScreen(matchType: 'result')),
                    );
                  },
                ),
                Divider(),
                _buildDrawerItem(
                  icon: Icons.login,
                  title: 'Login/Register',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer Section
          SafeArea(
            child: Column(
              children: [
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Logout action
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}

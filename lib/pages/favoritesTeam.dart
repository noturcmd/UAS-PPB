import 'package:flutter/material.dart';
import '../drawer/appDrawer.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Text('No favorites yet!'),
      ),
    );
  }
}

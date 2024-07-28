import 'package:chatapp/components/drawer_tile.dart';
import 'package:chatapp/pages/settings_page.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) {
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // header
          const DrawerHeader(
            child: Icon(Icons.note),
          ),
          // note tile
          DrawerTile(
              title: "Home",
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
              }),

          DrawerTile(
              title: "Settings",
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
              }),

          // Spacer to push the logout tile to the bottom
          Spacer(),

          // logout tile
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: DrawerTile(
                title: "Logout",
                leading: const Icon(Icons.logout),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  logout(context);
                }),
          ),
        ],
      ),
    );
  }
}

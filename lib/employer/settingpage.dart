import 'package:codehunt/auth/login.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
    final String employerEmail;
  const SettingsPage({super.key,required this.employerEmail});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginForm()),
                  (Route<dynamic> route) => false,
                );
              }),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              // Navigate to language settings
            },
          ),
          const ListTile(
            leading: Icon(Icons.delete),
            title: Text("Delet account"),
          )
        ],
      ),
    );
  }
}

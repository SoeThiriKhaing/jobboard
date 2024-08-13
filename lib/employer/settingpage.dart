import 'package:codehunt/seeker/seeker_mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final String employerEmail;
  const SettingsPage({super.key, required this.employerEmail});

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
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const SeekerMainpage(
                          seekerEmail: '',
                        )),
                (Route<dynamic> route) => false,
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.notifications),
          //   title: const Text('Notifications'),
          //   onTap: () {},
          // ),
          // ListTile(
          //   leading: const Icon(Icons.language),
          //   title: const Text('Language'),
          //   onTap: () {},
          // ),
          // const ListTile(
          //   leading: Icon(Icons.delete),
          //   title: Text("Delet account"),
          // )
        ],
      ),
    );
  }
}

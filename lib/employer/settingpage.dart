// import 'package:codehunt/auth/login.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.settings,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SettingsPage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             leading: const Icon(Icons.notifications),
//             title: const Text('Notifications'),
//             onTap: () {
//               // Navigate to notifications settings
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.language),
//             title: const Text('Language'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Sign Out'),
//             onTap: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => const LoginForm()),
//                 (Route<dynamic> route) => false,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:codehunt/auth/login.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
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
            onTap: () {
             
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              // Navigate to language settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delet account"),

          )
        ],
      ),
    );
  }
}
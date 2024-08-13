import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Admin Dashboard',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginForm()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        padding: const EdgeInsets.all(16),
        itemCount: 2, // Number of items in the grid
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildDashboardCard(
                context, 'Manage Job Posts', Icons.work, '/manageJobPosts');
          } else {
            return _buildDashboardCard(
                context, 'Manage Users', Icons.people, '/manageUsers');
          }
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    // Determine the number of columns based on the screen width
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 2; // Two columns for small screens
    } else {
      return 3; // Three columns for larger screens
    }
  }

  Widget _buildDashboardCard(
      BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: RegistrationForm.navyColor),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

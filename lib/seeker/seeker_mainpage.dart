import 'package:codehunt/auth/register.dart';
import 'package:codehunt/seeker/appliedjob.dart';
import 'package:codehunt/seeker/save_job.dart';
import 'package:codehunt/seeker/seeker_home.dart';
import 'package:codehunt/seeker/seeker_profile.dart';
import 'package:flutter/material.dart';

class SeekerMainpage extends StatefulWidget {
  const SeekerMainpage({super.key});

  @override
  SeekerMainpageState createState() => SeekerMainpageState();
}

class SeekerMainpageState extends State<SeekerMainpage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const SeekerHome(),
    const SavedJobsPage(),
    const AppliedJobsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: RegistrationForm.navyColor,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Applied Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

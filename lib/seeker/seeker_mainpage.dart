import 'package:codehunt/auth/register.dart';
import 'package:codehunt/seeker/appliedjob.dart';
import 'package:codehunt/seeker/my_activity.dart';
import 'package:codehunt/seeker/seeker_home.dart';
import 'package:codehunt/seeker/seeker_profile.dart';
import 'package:flutter/material.dart';

class SeekerMainpage extends StatefulWidget {
  const SeekerMainpage({super.key, required String seekerEmail});

  @override
  SeekerMainpageState createState() => SeekerMainpageState();
}

class SeekerMainpageState extends State<SeekerMainpage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const SeekerHome(
      seekerEmail: 'Jobseeker',
    ),
    const SavedJobPage(),
    const AppliedJobsPage(),
    const SeekerProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: RegistrationForm.navyColor,
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     "Find Your Dream IT Job Today",
      //     style: appBarTextStyle,
      //   ),
      // ),
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

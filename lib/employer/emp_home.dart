import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/home.dart';
import 'package:codehunt/employer/jobpostform.dart';
import 'package:codehunt/employer/managepost.dart';
import 'package:codehunt/employer/profile.dart';
import 'package:flutter/material.dart';

class EmployerPage extends StatefulWidget {
  const EmployerPage({super.key});

  @override
  EmployerPageState createState() => EmployerPageState();
}

class EmployerPageState extends State<EmployerPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    EmployerHomePage(),
    JobPostForm(),
    ManagePostsPage(),
    EmployerProfilePage(),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Post Job',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: 'Manage Job Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: RegistrationForm.navyColor,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/homepage.dart';
import 'package:codehunt/employer/managepost.dart';
import 'package:codehunt/employer/profile.dart';
import 'package:codehunt/form_decoration/appbarstyle.dart';
import 'package:flutter/material.dart';

class EmployerPage extends StatefulWidget {
  const EmployerPage({super.key});

  @override
  EmployerPageState createState() => EmployerPageState();
}

class EmployerPageState extends State<EmployerPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    EmpHomePage(),
    ManagePostsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Find The Best Tech',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
        selectedItemColor: RegistrationForm.navyColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

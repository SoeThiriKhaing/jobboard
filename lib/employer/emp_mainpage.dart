
// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/employer/emp_home.dart';
// import 'package:codehunt/employer/jobpostform.dart';
// import 'package:codehunt/employer/managepost.dart';
// import 'package:codehunt/employer/emp_profile.dart';
// import 'package:flutter/material.dart';

// class EmployerPage extends StatefulWidget {
//   final String employerEmail;

//   const EmployerPage({super.key, required this.employerEmail});

//   @override
//   EmployerPageState createState() => EmployerPageState();
// }

// class EmployerPageState extends State<EmployerPage> {
//   int _selectedIndex = 0;
//   late final List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _pages = <Widget>[
//       EmployerHomePage(employerEmail: widget.employerEmail),
//       JobPostForm(employerEmail: widget.employerEmail),
//       ManagePostsPage(employerEmail: widget.employerEmail),
//       EmployerProfile(employerEmail: widget.employerEmail),
//     ];
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.post_add),
//             label: 'Post Job',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.manage_search),
//             label: 'Manage Job Posts',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         unselectedItemColor: Colors.grey,
//         selectedItemColor: RegistrationForm.navyColor,
//         type: BottomNavigationBarType.fixed,
//         elevation: 20,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/emp_home.dart';
import 'package:codehunt/employer/jobpostform.dart';
import 'package:codehunt/employer/managepost.dart';
import 'package:codehunt/employer/emp_profile.dart';

class EmployerPage extends StatefulWidget {
  final String employerEmail;

  const EmployerPage({Key? key, required this.employerEmail}) : super(key: key);

  @override
  _EmployerPageState createState() => _EmployerPageState();
}

class _EmployerPageState extends State<EmployerPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      EmployerHomePage(employerEmail: widget.employerEmail),
      JobPostForm(employerEmail: widget.employerEmail),
      ManagePostsPage(employerEmail: widget.employerEmail),
      EmployerProfile(employerEmail: widget.employerEmail),
    ];
  }

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
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Post Job'),
          BottomNavigationBarItem(icon: Icon(Icons.manage_search), label: 'Manage Job Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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

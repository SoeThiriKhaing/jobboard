import 'package:codehunt/admin/admin.dart';
import 'package:codehunt/admin/manage_post.dart';
import 'package:codehunt/admin/manage_user.dart';
import 'package:codehunt/auth/splash_screen.dart';
import 'package:codehunt/employer/emp_home.dart';
import 'package:codehunt/seeker/seeker_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        '/admin': (context) => AdminPage(),
        '/manageUsers': (context) => ManageUsersPage(),
        '/manageJobPosts': (context) => ManageJobPostsPage(),
        '/seekerhome': (context) => const SeekerHome(
              seekerEmail: 'JobSeeker',
            ),
        'employerhome': (context) =>
            const EmployerHomePage(employerEmail: 'employer'),
      },
    );
  }
}

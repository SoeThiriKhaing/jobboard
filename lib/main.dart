import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/splash_screen.dart';
import 'package:codehunt/seeker/seeker_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/auth/login.dart';

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
      title: 'Flutter Registration Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        '/seekerhome': (contex) => const SeekerHome(),
      },
    );
  }
}

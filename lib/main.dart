import 'package:codehunt/auth/splash_screen.dart';
import 'package:codehunt/employer/emp_home.dart';
import 'package:codehunt/seeker/seeker_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<String?>(
    //     // future: _getLanguage(),
    //     builder: (context, snapshot) {
    //       Locale locale = Locale('en'); // Default locale

    //       if (snapshot.hasData) {
    //         locale = Locale(snapshot.data!);
    //       }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // locale: locale,
      // localizationsDelegates: [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: [
      //   Locale('en', ''), // English
      //   Locale('ja', ''), // Japanese
      //   Locale('my', ''), // Burmese
      //   Locale('id', ''), // Bahasa
      // ],
      home: const SplashScreen(),
      routes: {
        '/seekerhome': (context) => const SeekerHome(
              seekerEmail: 'JobSeeker',
            ),
        'employerhome': (context) =>
            const EmployerHomePage(employerEmail: 'employer'),
      },
    );
  }
}

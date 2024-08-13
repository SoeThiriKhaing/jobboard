import 'package:codehunt/admin/admin.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/auth/sharepreference.dart';
import 'package:codehunt/employer/emp_mainpage.dart';
import 'package:codehunt/seeker/seeker_mainpage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String? userRole;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    var role = await SharePreferenceService.getUseRole();

    print("SharedPref role is $role");
    setState(() {
      userRole = role;
    });

    if (userRole != null && userRole!.isNotEmpty) {
      print("Splash Screen role is $userRole");
      if (userRole == "Employer") {
        print("User role from splash screen is $userRole");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const EmployerPage(
                    employerEmail: 'employer', jobPostId: '',
                  )),
        );
      } else if (userRole == "Jobseeker") {
        print("Else block User role from splash screen is $userRole");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const SeekerMainpage(
                    seekerEmail: 'Jobseeker',
                  )),
        );
      }
    } else if (_emailController.text.trim() == "soethirikhaing846@gmail.com" &&
        _passwordController.text.trim() == "@#1admin") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminPage()));
    } else if (userRole == null &&
        _emailController.text.trim() != "soethirikhaing846@gmail.com" &&
        _passwordController.text.trim() != "@#1admin") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const SeekerMainpage(
                  seekerEmail: '',
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegistrationForm.navyColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipOval(
              child: Image.asset('assets/images/a.jpg', width: 80, height: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              'Code Hunt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

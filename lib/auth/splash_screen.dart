// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/auth/sharepreference.dart';
// import 'package:codehunt/employer/emp_mainpage.dart';
// import 'package:codehunt/seeker/seeker_mainpage.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   SplashScreenState createState() => SplashScreenState();
// }

// class SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkUserStatus();
//   }
//    Future<void> _checkUserStatus() async {
//     await Future.delayed(const Duration(seconds: 2));

//     String? role = await SharePreferenceService.getUseRole();

//     print("Sharepref role is $role");
//     setState(() {
//       userRole = role;
//     });

//     if (userRole != null && userRole!.isNotEmpty) {
//       print("Splash Scren in role is $userRole");
//       if (userRole!.contains("Employer")) {
//         print("User role form splash screen is $userRole");
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const AdminPanel()),
//         );
//       } else {
//         print("Else blok User role form splash screen is $userRole");

//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//         );
//       }
//     } else {
//       print("Login Page Screen");
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const Login()),
//       );
//     }
//   }


//   // _navigateToHome(BuildContext context) async {
//   //   await Future.delayed(
//   //       const Duration(seconds: 3)); 
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String? role = prefs.getString('role');

//   //   if (role == 'Jobseeker') {
//   //     _navigateToSeekerMainpage(context);
//   //   } else if (role == 'Employer') {
//   //     _navigateToEmployerPage(context);
//   //   } else {
//   //     _navigateToSeekerMainpage(
//   //         context); // Default to SeekerMainpage for unknown roles
//   //   }
//   // }

//   // void _navigateToSeekerMainpage(BuildContext context) {
//   //   if (Navigator.canPop(context)) {
//   //     Navigator.pop(context);
//   //   }
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (_) => const SeekerMainpage(
//   //         seekerEmail: 'Jobseeker',
//   //       ),
//   //     ),
//   //   );
//   // }

//   // void _navigateToEmployerPage(BuildContext context) {
//   //   if (Navigator.canPop(context)) {
//   //     Navigator.pop(context);
//   //   }
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (_) => const EmployerPage(
//   //         employerEmail: 'Employer',
//   //       ),
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: RegistrationForm.navyColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ClipOval(
//               child: Image.asset('assets/images/a.jpg', width: 80, height: 60),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Code Hunt',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/auth/sharepreference.dart';
import 'package:codehunt/employer/emp_mainpage.dart';
import 'package:codehunt/seeker/seeker_home.dart';
import 'package:codehunt/seeker/seeker_mainpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    String? role = await SharePreferenceService.getUseRole();

    print("SharedPref role is $role");
    setState(() {
      userRole = role;
    });

    if (userRole != null && userRole!.isNotEmpty) {
      print("Splash Screen role is $userRole");
      if (userRole == "Employer") {
        print("User role from splash screen is $userRole");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EmployerPage(employerEmail: 'employer',)),
        );
      } else {
        print("Else block User role from splash screen is $userRole");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SeekerHome(seekerEmail: 'Jobseekr',)),
        );
      }
    } else {
    
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SeekerMainpage(seekerEmail: 'Jobseeker',)),
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


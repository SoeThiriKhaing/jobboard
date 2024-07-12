import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/appbarstyle.dart';
import 'package:flutter/material.dart';

class JobseekerPage extends StatelessWidget {
  const JobseekerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Find Your Dream IT Job',style: appBarTextStyle,),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: const Center(
        child: Text('Welcome, Jobseeker!'),
      ),
    );
  }
}

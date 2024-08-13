import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/admin/admin.dart'; // Ensure this import is correct
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/auth/sharepreference.dart';
import 'package:codehunt/employer/emp_mainpage.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/form_decoration/boxdecoration.dart';
import 'package:codehunt/seeker/seeker_mainpage.dart';
import 'package:codehunt/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Check for hardcoded credentials for AdminPage
        if (_emailController.text.trim() == "soethirikhaing846@gmail.com" &&
            _passwordController.text.trim() == "@#1admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
          );
          return; // Exit after navigating to AdminPage
        }

        // Fetch user role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        var role = userDoc['role'];

        SharePreferenceService.saveUserRole(role);

        if (role == 'Jobseeker') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SeekerMainpage(seekerEmail: _emailController.text.trim())),
          );
        } else if (role == 'Employer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EmployerPage(
                      employerEmail: _emailController.text.trim(),
                      jobPostId: '',
                    )),
          );
        } else {
          _showErrorDialog('Invalid role.');
        }
        _clear();
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }
        _showErrorDialog(errorMessage);
      }
    }
  }

  Future<void> _forgotPassword() async {
    TextEditingController _resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Forgot Password',
            style: TextStyle(color: RegistrationForm.navyColor),
          ),
          content: TextField(
            controller: _resetEmailController,
            decoration: const InputDecoration(
              labelText: 'Enter your email',
              hintText: 'Email',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () async {
                if (_resetEmailController.text.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: _resetEmailController.text.trim(),
                    );
                    Navigator.of(context).pop();
                    _showInfoDialog('Password reset email sent.');
                  } on FirebaseAuthException catch (e) {
                    Navigator.of(context).pop();
                    _showErrorDialog(e.message ?? 'An error occurred.');
                  }
                } else {
                  _showErrorDialog('Please enter your email.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _clear() {
    _emailController.clear();
    _passwordController.clear();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Sign in',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/coder.jpg',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome To CodeHunt!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: RegistrationForm.navyColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: emailInputDecoration(),
                  validator: validateEmail,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: RegistrationForm.navyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: passwordInputDecoration(),
                  obscureText: true,
                  validator: validatePassword,
                ),
                const SizedBox(height: 20),
                Container(
                  width: _screenWidth,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RegistrationForm.navyColor,
                    ),
                    child: Text(
                      'Sign in',
                      style: btnTextStyle,
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegistrationForm()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Do not have an account? ',
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Register',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: RegistrationForm.navyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

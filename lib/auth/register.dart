import 'package:codehunt/auth/login.dart';
import 'package:codehunt/employer/emp_mainpage.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/seeker/seeker_mainpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/utils/validation.dart';
import 'package:codehunt/form_decoration/boxdecoration.dart';

class RegistrationForm extends StatefulWidget {
  static const Color navyColor = Color(0xFF000080);
  const RegistrationForm({super.key});

  @override
  RegistrationFormState createState() => RegistrationFormState();
}

class RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _role = 'Jobseeker';
  bool _agreedToPolicy = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _agreedToPolicy) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _role,
        });

        if (_role == 'Jobseeker') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const SeekerMainpage(
                      seekerEmail: 'Jobseeker',
                    )),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const EmployerPage(
                      employerEmail: 'employer', jobPostId: '',
                    )),
          );
        }
        _clear();
      } on FirebaseAuthException catch (e) {
        print('Error: $e');
      }
    }
  }

  void _clear() {
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RegistrationForm.navyColor,
        title: Text(
          'Register',
          style: appBarTextStyle,
        ),
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
                        'Find Your Dream IT Job!',
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
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: emailInputDecoration(),
                  validator: validateEmail,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: passwordInputDecoration(),
                  obscureText: true,
                  validator: validatePassword,
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Jobseeker', 'Employer'].map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _role = newValue!;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToPolicy,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreedToPolicy = value!;
                        });
                      },
                    ),
                    const Text('I agree to the privacy policy'),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: _screenWidth,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RegistrationForm.navyColor,
                    ),
                    child: Text(
                      'Register',
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
                            builder: (context) => const LoginForm()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Sign in',
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

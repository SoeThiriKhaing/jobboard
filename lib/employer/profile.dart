import 'dart:io';

import 'package:codehunt/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyDescriptionController = TextEditingController();
  File? _profileImage;

  Future<void> _updateProfile() async {
    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/${FirebaseAuth.instance.currentUser!.uid}.png');
        await storageRef.putFile(_profileImage!);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('employers').doc(FirebaseAuth.instance.currentUser!.uid).set({
        'companyName': _companyNameController.text,
        'companyDescription': _companyDescriptionController.text,
        'profileImage': profileImageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error: $e');
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationForm()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile fields and image upload
          ElevatedButton(
            onPressed: _updateProfile,
            child:const Text('Update Profile'),
          ),
          IconButton(
            icon:const Icon(Icons.settings),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => SettingsPage(logoutCallback: _logout)),
             
            },
          ),
        ],
      ),
    );
  }
}

// class SettingsPage extends StatelessWidget {
//   final VoidCallback logoutCallback;

//   const SettingsPage({required this.logoutCallback});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:

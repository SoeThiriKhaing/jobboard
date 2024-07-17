import 'dart:io';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/settingpage.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EmployerProfile extends StatefulWidget {
  const EmployerProfile({super.key, required this.employerEmail});

  final String employerEmail;

  @override
  EmployerProfileState createState() => EmployerProfileState();
}

class EmployerProfileState extends State<EmployerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _profileImageUrl;
  String _companyName = '';
  String _phoneNumber = '';
  String _location = '';

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    if (_user == null) return;

    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('employersprofile').doc(_user!.uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _profileImageUrl = data['profileImageUrl'] ?? '';
          _companyName = data['companyName'] ?? '';
          _phoneNumber = data['phoneNumber'] ?? '';
          _location = data['location'] ?? '';

          _companyNameController.text = _companyName;
          _phoneNumberController.text = _phoneNumber;
          _locationController.text = _location;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading profile data: $e');
      }
    }
  }

  Future<void> _updateProfileData() async {
    if (_user == null) return;

    try {
      await _firestore.collection('employersprofile').doc(_user!.uid).update({
        'profileImageUrl': _profileImageUrl,
        'companyName': _companyName,
        'phoneNumber': _phoneNumber,
        'location': _location,
      });
      if (kDebugMode) {
        print('Profile updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _profileImageUrl = imageFile.path;
      });
      _updateProfileData();
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (_user == null) {
    //   return const Center(
    //     child: Text('Please log in to see your profile.'),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SettingsPage(employerEmail: widget.employerEmail)),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl != null
                        ? FileImage(File(_profileImageUrl!))
                        : const AssetImage('assets/default_profile_image.png')
                            as ImageProvider,
                    child: _profileImageUrl == null
                        ? const Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Name: ${_user?.displayName ?? 'Employer'}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: ${_user!.email}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                onChanged: (value) {
                  setState(() {
                    _companyName = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfileData,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

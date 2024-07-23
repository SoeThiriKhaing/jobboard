import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/seeker/seeker_setting.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class SeekerProfile extends StatefulWidget {
  const SeekerProfile({super.key});

  @override
  SeekerProfileState createState() => SeekerProfileState();
}

class SeekerProfileState extends State<SeekerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  String? _profileImageUrl;
  String _location = '';
  String _education = '';
  String _skills = '';
  String _languages = '';
  String _fullName = '';
  String _description = '';
  String _visibility = 'Public'; // Default visibility

  // Original values
  String _originalLocation = '';
  String _originalEducation = '';
  String _originalSkills = '';
  String _originalLanguages = '';
  String _originalFullName = '';
  String _originalDescription = '';
  String _originalVisibility = '';

  bool _hasUnsavedChanges = false;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(_user!.uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _profileImageUrl = data['profileImageUrl'];
          _location = data['location'] ?? '';
          _education = data['education'] ?? '';
          _skills = data['skills'] ?? '';
          _languages = data['languages'] ?? '';
          _fullName = data['fullName'] ?? '';
          _description = data['description'] ?? '';
          _visibility = data['visibility'] ?? 'Public'; // Load visibility

          // Set original values
          _originalLocation = _location;
          _originalEducation = _education;
          _originalSkills = _skills;
          _originalLanguages = _languages;
          _originalFullName = _fullName;
          _originalDescription = _description;
          _originalVisibility = _visibility;

          _locationController.text = _location;
          _educationController.text = _education;
          _skillsController.text = _skills;
          _languagesController.text = _languages;
          _fullNameController.text = _fullName;
          _descriptionController.text = _description;
        });
      }
    }
  }

  Future<void> _updateProfileData() async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).update({
      'profileImageUrl': _profileImageUrl,
      'location': _location,
      'education': _education,
      'skills': _skills,
      'languages': _languages,
      'fullName': _fullName,
      'description': _description,
      'visibility': _visibility, // Save visibility
    });
    setState(() {
      // After updating, mark as no unsaved changes
      _hasUnsavedChanges = false;
    });
  }

  void _onTextFieldChanged() {
    setState(() {
      _hasUnsavedChanges = _location != _originalLocation ||
          _education != _originalEducation ||
          _skills != _originalSkills ||
          _languages != _originalLanguages ||
          _fullName != _originalFullName ||
          _description != _originalDescription ||
          _visibility != _originalVisibility; // Check visibility change
    });
  }

  Future<void> _pickProfileImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      try {
        final storageRef = _storage.ref().child('profileImages/${_user!.uid}');
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() {});
        final imageUrl = await snapshot.ref.getDownloadURL();

        if (mounted) {
          setState(() {
            _profileImageUrl = imageUrl;
          });
          _updateProfileData();
        }
      } catch (e) {
        // Handle errors
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _pickFile(TextEditingController controller) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      try {
        final storageRef = _storage
            .ref()
            .child('uploads/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final fileUrl = await snapshot.ref.getDownloadURL();

        if (mounted) {
          setState(() {
            controller.text = fileUrl;
          });
          _updateProfileData();
        }
      } catch (e) {
        // Handle errors
        print('Error uploading file: $e');
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
    _fullNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: appBarTextStyle,
          ),
          backgroundColor: RegistrationForm.navyColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text("Please log in to see your profile"),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              width: screenWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginForm()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: RegistrationForm.navyColor,
                ),
                child: Text(
                  'Sign in',
                  style: btnTextStyle,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RegistrationForm.navyColor,
        title: Text(
          'Profile',
          style: appBarTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SeekerSetting()));
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : const AssetImage(
                                    'assets/default_profile_image.png')
                                as ImageProvider,
                        child: _profileImageUrl == null
                            ? const Icon(Icons.add_a_photo)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: const Text('Full Name'),
                      subtitle: TextField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your full name',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _fullName = value;
                          });
                          _onTextFieldChanged();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: const Text('Location'),
                      subtitle: TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your location',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _location = value;
                          });
                          _onTextFieldChanged();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: const Text('Education'),
                      subtitle: TextField(
                        controller: _educationController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your education',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _education = value;
                          });
                          _onTextFieldChanged();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: const Text('Skills'),
                      subtitle: TextField(
                        controller: _skillsController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your skills',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _skills = value;
                          });
                          _onTextFieldChanged();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: const Text('Languages'),
                      subtitle: TextField(
                        controller: _languagesController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter languages',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _languages = value;
                          });
                          _onTextFieldChanged();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: const Text('Description'),
                      subtitle: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter a description',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                          _onTextFieldChanged();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: const Text('Profile Visibility'),
                      subtitle: DropdownButton<String>(
                        value: _visibility,
                        onChanged: (String? newValue) {
                          setState(() {
                            _visibility = newValue!;
                          });
                          _onTextFieldChanged();
                        },
                        items: <String>['Public', 'Private']
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: screenWidth,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _hasUnsavedChanges
                    ? () async {
                        await _updateProfileData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully'),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RegistrationForm.navyColor,
                ),
                child: Text(
                  'Save Profile',
                  style: btnTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

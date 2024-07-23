import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/seeker/seeker_setting.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart'; 

class EmployerProfile extends StatefulWidget {
  const EmployerProfile({super.key, required this.employerEmail});

  final String employerEmail;

  @override
  EmployerProfileState createState() => EmployerProfileState();
}

class EmployerProfileState extends State<EmployerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  String? _profileImageUrl;
  String? _backgroundImageUrl;

  String _companyName = '';
  String _email = '';
  String _websiteUrl = '';
  String _location = '';
  String _description = '';
  String _industry = '';
  String _size = '';
  String _foundingDate = '';

  bool _hasUnsavedChanges = false;
  bool _showMore = false;

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _foundingDateController = TextEditingController();

  var logger = Logger();

  @override
  void initState() {
    super.initState();

    logger.d("REACH HERE");
    _user = _auth.currentUser;

    logger.d("User is $_user");

    if (_user != null) {
      _emailController.text = _user!.email ?? '';
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
          _backgroundImageUrl = data['backgroundImageUrl'];
          _companyName = data['companyName'] ?? '';
          _email = data['email'] ?? '';
          _websiteUrl = data['websiteUrl'] ?? '';
          _location = data['location'] ?? '';
          _description = data['description'] ?? '';
          _industry = data['industry'] ?? '';
          _size = data['size'] ?? '';
          _foundingDate = data['foundingDate'] ?? '';

          _companyNameController.text = _companyName;
          _emailController.text = _email;
          _websiteUrlController.text = _websiteUrl;
          _locationController.text = _location;
          _descriptionController.text = _description;
          _industryController.text = _industry;
          _sizeController.text = _size;
          _foundingDateController.text = _foundingDate;
        });
      }
    } else {
      print("No Data");
    }
  }

  Future<void> _updateProfileData() async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).update({
      'profileImageUrl': _profileImageUrl,
      'backgroundImageUrl': _backgroundImageUrl,
      'companyName': _companyName,
      'email': _email,
      'websiteUrl': _websiteUrl,
      'location': _location,
      'description': _description,
      'industry': _industry,
      'size': _size,
      'foundingDate': _foundingDate,
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
            _hasUnsavedChanges = true;
          });
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _pickBackgroundImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      try {
        final storageRef =
            _storage.ref().child('backgroundImages/${_user!.uid}');
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() {});
        final imageUrl = await snapshot.ref.getDownloadURL();

        if (mounted) {
          setState(() {
            _backgroundImageUrl = imageUrl;
            _hasUnsavedChanges = true;
          });
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _selectFoundingDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _foundingDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        _foundingDateController.text = _foundingDate;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _handleSaveButton() async {
    await _updateProfileData();
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _websiteUrlController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _industryController.dispose();
    _sizeController.dispose();
    _foundingDateController.dispose();
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Please log in to see your profile"),
              const SizedBox(height: 30.0),
              ElevatedButton(
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
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RegistrationForm.navyColor,
        title: Text(
          'Company Profile',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      GestureDetector(
                        onTap: _pickBackgroundImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            image: _backgroundImageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_backgroundImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _backgroundImageUrl == null
                              ? const Center(
                                  child: Text(
                                    'Add Background Image',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 54.0, left: 16, right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null,
                                child: _profileImageUrl == null
                                    ? const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.white,
                                        size: 40,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _companyNameController,
                          decoration: const InputDecoration(
                            labelText: 'Company Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _companyName = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Company Email',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _email = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _websiteUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Company Website URL',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _websiteUrl = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Company Location',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _location = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: _showMore ? null : 2,
                          decoration: InputDecoration(
                            labelText: 'Company Description',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showMore
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showMore = !_showMore;
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _description = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _industryController,
                          decoration: const InputDecoration(
                            labelText: 'Industry',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _industry = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _sizeController,
                          decoration: const InputDecoration(
                            labelText: 'Company Size',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _size = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () => _selectFoundingDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _foundingDateController,
                              decoration: const InputDecoration(
                                labelText: 'Founding Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _hasUnsavedChanges,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: _handleSaveButton,
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
          ),
        ],
      ),
    );
  }
}

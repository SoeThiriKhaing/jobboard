import 'dart:io';

import 'package:codehunt/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:codehunt/auth/firestore.dart';
import 'package:codehunt/employer/emp_data.dart';
import 'package:codehunt/employer/settingpage.dart';
import 'package:codehunt/form_decoration/appbarstyle.dart';

class EmployerProfilePage extends StatefulWidget {
  const EmployerProfilePage({super.key});

  @override
  EmployerProfilePageState createState() => EmployerProfilePageState();
}

class EmployerProfilePageState extends State<EmployerProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Employer? employer; // Ensure employer is nullable

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchEmployerData();
  }

  Future<void> _fetchEmployerData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      Employer emp = await _firestoreService.getEmployer(user.uid);
      setState(() {
        employer = emp;
      });
    }
  }

  void _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Find The Best Tech',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: employer == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (employer!.profileImage.isNotEmpty
                              ? NetworkImage(employer!.profileImage)
                              : const AssetImage('assets/coder.jpg')
                                  as ImageProvider),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Email: ${employer!.companyEmail}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Phone: ${employer!.phoneNumber}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Location: ${employer!.location}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Job Description: ${employer!.jobDescription}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditEmployerProfilePage(employer: employer!),
                        ),
                      ).then((updatedEmployer) {
                        if (updatedEmployer != null) {
                          setState(() {
                            employer = updatedEmployer;
                          });
                        }
                      });
                    },
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}

class EditEmployerProfilePage extends StatefulWidget {
  final Employer employer;

  const EditEmployerProfilePage({super.key, required this.employer});

  @override
  EditEmployerProfilePageState createState() =>
      EditEmployerProfilePageState();
}

class EditEmployerProfilePageState extends State<EditEmployerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _profileImageController = TextEditingController();
  final TextEditingController _companyEmailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _profileImageController.text = widget.employer.profileImage;
    _companyEmailController.text = widget.employer.companyEmail;
    _phoneNumberController.text = widget.employer.phoneNumber;
    _locationController.text = widget.employer.location;
    _jobDescriptionController.text = widget.employer.jobDescription;
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      Employer updatedEmployer = Employer(
        id: widget.employer.id,
        profileImage: _profileImageController.text,
        companyEmail: _companyEmailController.text,
        phoneNumber: _phoneNumberController.text,
        location: _locationController.text,
        jobDescription: _jobDescriptionController.text,
      );

      await _firestoreService.updateEmployer(updatedEmployer);
      Navigator.pop(context, updatedEmployer);
    }
  }

  void _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        _profileImageController.text = ''; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Employer Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _profileImageController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Profile Image URL',
                  suffixIcon: IconButton(
                    icon:const Icon(Icons.image),
                    onPressed: _pickImageFromGallery,
                  ),
                ),
              ),
              TextFormField(
                controller: _companyEmailController,
                decoration: const InputDecoration(labelText: 'Company Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the company email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jobDescriptionController,
                decoration: const InputDecoration(labelText: 'Job Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the job description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

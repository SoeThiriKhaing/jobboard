import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicationForm extends StatefulWidget {
  final String jobPostId;
  final String seekerEmail;
  final Map<String, dynamic> jobPostData;

  const JobApplicationForm({
    super.key,
    required this.jobPostId,
    required this.jobPostData,
    required this.seekerEmail,
  });

  @override
  JobApplicationFormState createState() => JobApplicationFormState();
}

class JobApplicationFormState extends State<JobApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  PlatformFile? _resumeFile;
  XFile? _profileImage;
  String? _profileImageUrl;
  String? _resumeUrl;
  bool _alreadyApplied = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _fetchProfileData(user.uid);
      _checkIfAlreadyApplied();
    }
  }

  Future<void> _fetchProfileData(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['fullName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _locationController.text = data['location'] ?? '';
          _profileImageUrl = data['profileImageUrl'];
          _educationController.text = data['education'] ?? '';
          _skillController.text = data['skills'] ?? '';
          _languagesController.text = data['languages'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  Future<void> _checkIfAlreadyApplied() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('job_applications')
          .where('applicantId', isEqualTo: user.uid)
          .where('jobPostId', isEqualTo: widget.jobPostId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _alreadyApplied = true;
        });
      }
    }
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'pptx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _resumeFile = result.files.first;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _uploadFile(
      String filePath, String fileName, String field) async {
    final file = File(filePath);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('$field/${widget.seekerEmail}/$fileName');
    final uploadTask = storageRef.putFile(file);

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    setState(() {
      if (field == 'resumes') {
        _resumeUrl = downloadUrl;
      } else if (field == 'profile_images') {
        _profileImageUrl = downloadUrl;
      }
    });
  }

  Future<void> _submitApplication(String jobPostId) async {
    if (_formKey.currentState!.validate() && !_alreadyApplied) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (_resumeFile != null) {
          await _uploadFile(_resumeFile!.path!, _resumeFile!.name, 'resumes');
        }

        if (_profileImage != null) {
          await _uploadFile(
              _profileImage!.path, _profileImage!.name, 'profile_images');
        }

        final applicationData = {
          'jobPostId': jobPostId,
          'applicantId': user.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'location': _locationController.text,
          'education': _educationController.text,
          'skill': _skillController.text,
          'language': _languagesController.text,
          'coverLetter': _coverLetterController.text,
          'applicationDate': Timestamp.now(),
          'profileImageUrl': _profileImageUrl,
          'resumeUrl': _resumeUrl,
          'submittedBy': widget.seekerEmail,
        };

        await FirebaseFirestore.instance
            .collection('job_applications')
            .add(applicationData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be signed in to apply.')),
        );
      }
    } else if (_alreadyApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already applied for this job.')),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Apply for ${widget.jobPostData['title']}',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _educationController,
                    decoration: const InputDecoration(
                      labelText: "Education",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      labelText: "Skills",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _languagesController,
                    decoration: const InputDecoration(
                      labelText: "Languages",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _coverLetterController,
                    decoration: const InputDecoration(
                      labelText: 'Cover Letter',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a cover letter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: _screenWidth,
                    child: ElevatedButton.icon(
                      onPressed: _pickResume,
                      icon: const Icon(Icons.upload_file),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      label: Text(
                        'Upload Resume',
                        style: dashTextStyle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_resumeFile != null)
                    Text(
                      'Selected file: ${_resumeFile!.name}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 10),
                  if (_resumeUrl != null)
                    ElevatedButton(
                      onPressed: () => _launchURL(_resumeUrl!),
                      child: Text(
                        'View Resume',
                        style: btnTextStyle,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    width: _screenWidth,
                    child: ElevatedButton(
                      onPressed: () => _submitApplication(widget.jobPostId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RegistrationForm.navyColor,
                      ),
                      child: Text(
                        'Submit Application',
                        style: btnTextStyle,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

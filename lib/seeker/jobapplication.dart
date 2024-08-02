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
  final String jobPostTitle;

  final Map<String, dynamic> jobPostData;

  const JobApplicationForm({
    super.key,
    required this.jobPostId,
    required this.jobPostData,
    required this.seekerEmail,
    required String employerEmail,
    required this.jobPostTitle,
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
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _jobtitleController = TextEditingController();

  PlatformFile? _resumeFile;
  PlatformFile? _coverLetterFile;
  String? _profileImageUrl;
  String? _coverLetter;
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
          _descriptionController.text = data['description'] ?? '';
          _jobtitleController.text = data['title'] ?? '';
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

  Future<void> _pickCoverLetter() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'pptx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _coverLetterFile = result.files.first;
      });
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
      } else if (field == 'coverletter') {
        _coverLetter = downloadUrl;
      }
    });
  }

  Future<void> _submitApplication(String jobPostId) async {
    if (_formKey.currentState!.validate() &&
        _resumeFile != null &&
        _coverLetterFile != null &&
        !_alreadyApplied) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final jobPostDoc = await FirebaseFirestore.instance
            .collection('job_posts')
            .doc(jobPostId)
            .get();

        if (!jobPostDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job post not found.')),
          );
          return;
        }

        final jobPostTitle = jobPostDoc.data()?['title'] ?? 'Unknown Title';

        final applicationData = {
          'jobPostId': jobPostId,
          'jobPostTitle': jobPostTitle,
          'applicantId': user.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'location': _locationController.text,
          'education': _educationController.text,
          'skill': _skillController.text,
          'language': _languagesController.text,
          'description': _descriptionController.text,
          'coverLetter': _coverLetter,
          'applicationDate': Timestamp.now(),
          'profileImageUrl': _profileImageUrl,
          'resumeUrl': _resumeUrl,
          'submittedBy': widget.seekerEmail,
        };

        await FirebaseFirestore.instance
            .collection('job_applications')
            .add(applicationData);

        final employerEmail = widget.jobPostData['postedBy'];
        if (employerEmail == null || employerEmail.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employer email not provided.')),
          );
          return;
        }

        final subject = 'Job Application for $jobPostTitle'; // Use jobPostTitle
        final body = '''
      Name: ${_nameController.text}
      Email: ${_emailController.text}
      JobTitle:${_jobtitleController.text}
      Location: ${_locationController.text}
      Education: ${_educationController.text}
      Skills: ${_skillController.text}
      Languages: ${_languagesController.text}
      Description: ${_descriptionController.text}
      Cover Letter: ${_coverLetter}
      Resume: ${_resumeUrl}
      Profile Image: ${_profileImageUrl}
      Application Date: ${DateTime.now()}
      ''';

        // Use url_launcher to open email client with prefilled email
        final uri = Uri(
          scheme: 'mailto',
          path: employerEmail,
          queryParameters: {
            'subject': subject,
            'body': body,
          },
        );
        await launchUrl(uri);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be signed in to apply.')),
        );
      }
    } else if (_resumeFile == null || _coverLetterFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload both cover letter and resume.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
        padding: const EdgeInsets.all(3.0),
        child: Card(
          color: Colors.white,
          elevation: 3,
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
                  _buildTextFormField(_nameController, 'Full Name'),
                  const SizedBox(height: 20),
                  _buildTextFormField(_emailController, 'Email',
                      readOnly: true),
                  const SizedBox(height: 20),
                  _buildTextFormField(_locationController, 'Location'),
                  const SizedBox(height: 20),
                  _buildTextFormField(_educationController, 'Education'),
                  const SizedBox(height: 20),
                  _buildTextFormField(_skillController, 'Skills'),
                  const SizedBox(height: 20),
                  _buildTextFormField(_languagesController, 'Languages'),
                  const SizedBox(height: 20),
                  _buildTextFormField(_descriptionController, 'Description'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth,
                    child: ElevatedButton.icon(
                      onPressed: _pickCoverLetter,
                      icon: const Icon(Icons.upload_file),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      label: Text(
                        'Upload Cover Letter',
                        style: dashTextStyle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: screenWidth,
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
                  const SizedBox(height: 20),
                  _alreadyApplied
                      ? const Text('You have already applied for this job.')
                      : Container(
                          width: screenWidth,
                          child: ElevatedButton(
                            onPressed: () {
                              _submitApplication(widget.jobPostId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RegistrationForm.navyColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              'Submit Application',
                              style: btnTextStyle,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
        ),
      ),
    );
  }
}

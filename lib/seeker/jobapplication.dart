import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
    required this.jobPostTitle,
    required String employerEmail,
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

  Future<String?> _uploadFile(PlatformFile? file, String folder) async {
    if (file == null) return null;

    final filePath = file.path;
    if (filePath == null) return null;

    final fileName = file.name;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('$folder/${widget.seekerEmail}/$fileName');
    final uploadTask = storageRef.putFile(File(filePath));

    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submitApplication(String jobPostId) async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (_resumeFile != null) {
          _resumeUrl = await _uploadFile(_resumeFile, 'resumes');
        }
        if (_coverLetterFile != null) {
          _coverLetter = await _uploadFile(_coverLetterFile, 'coverletters');
        }

        if (_resumeUrl == null || _coverLetter == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please upload both cover letter and resume.'),
            ),
          );
          return;
        }

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

        final applicationData = {
          'jobPostId': jobPostId,
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

        final body = '''
        Name: ${_nameController.text}
        Email: ${_emailController.text}
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be signed in to apply.')),
        );
      }
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
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: RegistrationForm.navyColor, // Replace with your color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_profileImageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Center(
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: ClipOval(
                                child: Image.network(
                                  _profileImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      _buildCardTextField(_nameController, 'Full Name'),
                      _buildCardTextField(_emailController, 'Email'),
                      _buildCardTextField(_locationController, 'Location'),
                      _buildCardTextField(_educationController, 'Education'),
                      _buildCardTextField(_skillController, 'Skills'),
                      _buildCardTextField(_languagesController, 'Languages'),
                      _buildCardTextField(
                        _descriptionController,
                        'Description',
                        maxLines: 4,
                      ),
                      SizedBox(height: 16.0),
                      Container(
                        width: screenWidth,
                        child: ElevatedButton(
                          onPressed: _pickResume,
                          child: const Text('Pick Resume'),
                        ),
                      ),
                      if (_resumeFile != null) Text(_resumeFile!.name),
                      Container(
                        width: screenWidth,
                        child: ElevatedButton(
                          onPressed: _pickCoverLetter,
                          child: const Text('Pick Cover Letter'),
                        ),
                      ),
                      if (_coverLetterFile != null)
                        Text(_coverLetterFile!.name),
                      SizedBox(height: 16.0),
                      _alreadyApplied
                          ? const Text(
                              'You have already applied for this job.',
                              style: TextStyle(color: Colors.red),
                            )
                          : Container(
                              width: screenWidth,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _submitApplication(widget.jobPostId),
                                child: Text(
                                  'Submit Application',
                                  style: btnTextStyle,
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        RegistrationForm.navyColor),
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
    );
  }

  Widget _buildCardTextField(TextEditingController controller, String labelText,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: labelText,
              contentPadding: const EdgeInsets.all(16.0),
            ),
            maxLines: maxLines,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $labelText';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/form_decoration/textstyle.dart';
// import 'package:url_launcher/url_launcher.dart';

// class JobApplicationForm extends StatefulWidget {
//   final String jobPostId;
//   final String seekerEmail;
//   final Map<String, dynamic> jobPostData;

//   const JobApplicationForm({
//     super.key,
//     required this.jobPostId,
//     required this.jobPostData,
//     required this.seekerEmail,
//   });

//   @override
//   JobApplicationFormState createState() => JobApplicationFormState();
// }

// class JobApplicationFormState extends State<JobApplicationForm> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _coverLetterController = TextEditingController();
//   PlatformFile? _resumeFile;
//   XFile? _profileImage;
//   String? _profileImageUrl;
//   String? _resumeUrl;

//   @override
//   void initState() {
//     super.initState();
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _emailController.text = user.email ?? '';
//     }
//   }

//   Future<void> _pickResume() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'doc', 'docx', 'pptx'],
//     );

//     if (result != null && result.files.isNotEmpty) {
//       setState(() {
//         _resumeFile = result.files.first;
//       });
//     }
//   }

//   Future<void> _pickProfileImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     if (image != null) {
//       setState(() {
//         _profileImage = image;
//       });
//     }
//   }

//   Future<void> _uploadFile(
//       String filePath, String fileName, String field) async {
//     final file = File(filePath);
//     final storageRef = FirebaseStorage.instance
//         .ref()
//         .child('$field/${widget.seekerEmail}/$fileName');
//     final uploadTask = storageRef.putFile(file);

//     final snapshot = await uploadTask;
//     final downloadUrl = await snapshot.ref.getDownloadURL();

//     setState(() {
//       if (field == 'resumes') {
//         _resumeUrl = downloadUrl;
//       } else if (field == 'profile_images') {
//         _profileImageUrl = downloadUrl;
//       }
//     });
//   }

//   Future<void> _submitApplication() async {
//     if (_formKey.currentState!.validate()) {
//       final user = FirebaseAuth.instance.currentUser;

//       if (user != null) {
//         if (_resumeFile != null) {
//           await _uploadFile(_resumeFile!.path!, _resumeFile!.name, 'resumes');
//         }

//         if (_profileImage != null) {
//           await _uploadFile(
//               _profileImage!.path, _profileImage!.name, 'profile_images');
//         }

//         final applicationData = {
//           'jobPostId': widget.jobPostId,
//           'applicantId': user.uid,
//           'name': _nameController.text,
//           'email': _emailController.text,
//           'phone': _phoneController.text,
//           'location': _locationController.text,
//           'coverLetter': _coverLetterController.text,
//           'applicationDate': Timestamp.now(),
//           'profileImageUrl': _profileImageUrl,
//           'resumeUrl': _resumeUrl,
//           'submitby': widget.seekerEmail,
//         };

//         await FirebaseFirestore.instance
//             .collection('job_applications')
//             .add(applicationData);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Application submitted successfully!')),
//         );

//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('You need to be signed in to apply.')),
//         );
//       }
//     }
//   }

//   Future<void> _launchURL(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           'Apply for ${widget.jobPostData['title']}',
//           style: appBarTextStyle,
//         ),
//         backgroundColor: RegistrationForm.navyColor,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Job Details',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: RegistrationForm.navyColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 widget.jobPostData['title'],
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: _pickProfileImage,
//                 icon: const Icon(Icons.photo),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: RegistrationForm.navyColor,
//                 ),
//                 label: Text(
//                   'Upload Profile Image',
//                   style: btnTextStyle,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (_profileImage != null)
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: FileImage(File(_profileImage!.path)),
//                 ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Full Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your full name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 readOnly: true,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _locationController,
//                 decoration: const InputDecoration(
//                   labelText: "Location",
//                   border: OutlineInputBorder(),
//                 ),
//                 readOnly: true,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               TextFormField(
//                 controller: _coverLetterController,
//                 decoration: const InputDecoration(
//                   labelText: 'Cover Letter',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 5,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a cover letter';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: _pickResume,
//                 icon: const Icon(Icons.upload_file),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: RegistrationForm.navyColor,
//                 ),
//                 label: Text(
//                   'Upload Resume',
//                   style: btnTextStyle,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (_resumeFile != null)
//                 Text(
//                   'Selected file: ${_resumeFile!.name}',
//                   style: const TextStyle(fontStyle: FontStyle.italic),
//                 ),
//               const SizedBox(height: 20),
//               if (_resumeUrl != null)
//                 ElevatedButton(
//                   onPressed: () => _launchURL(_resumeUrl!),
//                   child: Text(
//                     'View Resume',
//                     style: btnTextStyle,
//                   ),
//                 ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitApplication,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: RegistrationForm.navyColor,
//                 ),
//                 child: Text(
//                   'Submit Application',
//                   style: btnTextStyle,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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
    Key? key,
    required this.jobPostId,
    required this.jobPostData,
    required this.seekerEmail,
  }) : super(key: key);

  @override
  _JobApplicationFormState createState() => _JobApplicationFormState();
}

class _JobApplicationFormState extends State<JobApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
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
      _checkIfAlreadyApplied();
    }
  }

  Future<void> _checkIfAlreadyApplied() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('job_applications')
          .where('jobPostId', isEqualTo: widget.jobPostId)
          .where('applicantId', isEqualTo: user.uid)
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

  Future<void> _submitApplication() async {
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
          'jobPostId': widget.jobPostId,
          'applicantId': user.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'coverLetter': _coverLetterController.text,
          'applicationDate': Timestamp.now(),
          'profileImageUrl': _profileImageUrl,
          'resumeUrl': _resumeUrl,
          'submitby': widget.seekerEmail,
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Job Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: RegistrationForm.navyColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.jobPostData['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickProfileImage,
                icon: const Icon(Icons.photo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RegistrationForm.navyColor,
                ),
                label: Text(
                  'Upload Profile Image',
                  style: btnTextStyle,
                ),
              ),
              const SizedBox(height: 20),
              if (_profileImage != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(File(_profileImage!.path)),
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
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(
                height: 20,
              ),
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
              ElevatedButton.icon(
                onPressed: _pickResume,
                icon: const Icon(Icons.upload_file),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RegistrationForm.navyColor,
                ),
                label: Text(
                  'Upload Resume',
                  style: btnTextStyle,
                ),
              ),
              const SizedBox(height: 20),
              if (_resumeFile != null)
                Text(
                  'Selected file: ${_resumeFile!.name}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              const SizedBox(height: 20),
              if (_resumeUrl != null)
                ElevatedButton(
                  onPressed: () => _launchURL(_resumeUrl!),
                  child: Text(
                    'View Resume',
                    style: btnTextStyle,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RegistrationForm.navyColor,
                ),
                child: Text(
                  'Submit Application',
                  style: btnTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


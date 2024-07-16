// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/form_decoration/textstyle.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';

// class JobApplicationForm extends StatefulWidget {
//   final String jobPostId;
//   final Map<String, dynamic> jobPostData;

//   const JobApplicationForm({
//     super.key,
//     required this.jobPostId,
//     required this.jobPostData,
//   });

//   @override
//   JobApplicationFormState createState() => JobApplicationFormState();
// }

// class JobApplicationFormState extends State<JobApplicationForm> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _coverLetterController = TextEditingController();
//   PlatformFile? _resumeFile;

//   Future<void> _pickResume() async {
//     final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx', 'pptx']);

//     if (result != null && result.files.isNotEmpty) {
//       setState(() {
//         _resumeFile = result.files.first;
//       });
//     }
//   }

//   Future<void> _submitApplication() async {
//     if (_formKey.currentState!.validate()) {
//       final user = FirebaseAuth.instance.currentUser;

//       if (user != null) {
//         final applicationData = {
//           'jobPostId': widget.jobPostId,
//           'applicantId': user.uid,
//           'name': _nameController.text,
//           'email': _emailController.text,
//           'phone': _phoneController.text,
//           'coverLetter': _coverLetterController.text,
//           'applicationDate': Timestamp.now(),
//         };

//         if (_resumeFile != null) {
//           applicationData['resumeFileName'] = _resumeFile!.name;
//         }

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
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null;
//                 },
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';

class JobApplicationForm extends StatefulWidget {
  final String jobPostId;
  final Map<String, dynamic> jobPostData;

  const JobApplicationForm({
    Key? key,
    required this.jobPostId,
    required this.jobPostData,
  }) : super(key: key);

  @override
  _JobApplicationFormState createState() => _JobApplicationFormState();
}

class _JobApplicationFormState extends State<JobApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  PlatformFile? _resumeFile;

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

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final applicationData = {
          'jobPostId': widget.jobPostId,
          'applicantId': user.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'coverLetter': _coverLetterController.text,
          'applicationDate': Timestamp.now(),
        };

        if (_resumeFile != null) {
          applicationData['resumeFileName'] = _resumeFile!.name;
        }

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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
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

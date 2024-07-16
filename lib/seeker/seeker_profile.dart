// import 'package:codehunt/auth/login.dart';
// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/employer/settingpage.dart';
// import 'package:codehunt/form_decoration/textstyle.dart';
// import 'package:codehunt/seeker/seeker_setting.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class SeekerProfile extends StatefulWidget {
//   const SeekerProfile({super.key});

//   @override
//   SeekerProfileState createState() => SeekerProfileState();
// }

// class SeekerProfileState extends State<SeekerProfile> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late User _user;
//   String? _profileImageUrl;
//   String _location = '';
//   String _resume = '';
//   String _coverLetter = '';
//   String _education = '';
//   String _skills = '';
//   String _languages = '';

//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _resumeController = TextEditingController();
//   final TextEditingController _coverLetterController = TextEditingController();
//   final TextEditingController _educationController = TextEditingController();
//   final TextEditingController _skillsController = TextEditingController();
//   final TextEditingController _languagesController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _user = _auth.currentUser!;
//     if (_user != null) {
//       _loadProfileData();
//     } else {}
//   }

//   Future<void> _loadProfileData() async {
//     DocumentSnapshot snapshot =
//         await _firestore.collection('users').doc(_user.uid).get();
//     if (snapshot.exists) {
//       Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
//       if (mounted) {
//         setState(() {
//           _profileImageUrl = data.containsKey('profileImageUrl')
//               ? data['profileImageUrl']
//               : null;
//           _location = data.containsKey('location') ? data['location'] : '';
//           _resume = data.containsKey('resume') ? data['resume'] : '';
//           _coverLetter =
//               data.containsKey('coverLetter') ? data['coverLetter'] : '';
//           _education = data.containsKey('education') ? data['education'] : '';
//           _skills = data.containsKey('skills') ? data['skills'] : '';
//           _languages = data.containsKey('languages') ? data['languages'] : '';

//           _locationController.text = _location;
//           _resumeController.text = _resume;
//           _coverLetterController.text = _coverLetter;
//           _educationController.text = _education;
//           _skillsController.text = _skills;
//           _languagesController.text = _languages;
//         });
//       }
//     }
//   }

//   Future<void> _updateProfileData() async {
//     await _firestore.collection('users').doc(_user.uid).update({
//       'profileImageUrl': _profileImageUrl,
//       'location': _location,
//       'resume': _resume,
//       'coverLetter': _coverLetter,
//       'education': _education,
//       'skills': _skills,
//       'languages': _languages,
//     });
//   }

//   Future<void> _pickProfileImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       File imageFile = File(pickedFile.path);
//       // Here you can upload the image file to your storage and get the URL
//       // For example, using Firebase Storage, and then update _profileImageUrl
//       // For simplicity, we are just setting the path to _profileImageUrl
//       if (mounted) {
//         setState(() {
//           _profileImageUrl = imageFile.path;
//         });
//         _updateProfileData();
//       }
//     }
//   }

//   Future<void> _pickFile(TextEditingController controller) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       File file = File(result.files.single.path!);
//       // Here you can upload the file to your storage and get the URL
//       // For simplicity, we are just setting the path to the controller's text
//       if (mounted) {
//         setState(() {
//           controller.text = file.path;
//         });
//         _updateProfileData();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _locationController.dispose();
//     _resumeController.dispose();
//     _coverLetterController.dispose();
//     _educationController.dispose();
//     _skillsController.dispose();
//     _languagesController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(
//             "Profile",
//             style: appBarTextStyle,
//           ),
//           backgroundColor: RegistrationForm.navyColor,
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Center(
//               child: Text("Please log in to see your profile"),
//             ),
//             const SizedBox(
//               height: 30.0,
//             ),
//             Container(
//               padding: const EdgeInsets.all(12.0),
//               width: screenWidth,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const LoginForm()));
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: RegistrationForm.navyColor,
//                 ),
//                 child: Text(
//                   'Sign in',
//                   style: btnTextStyle,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: RegistrationForm.navyColor,
//         title: Text(
//           'Profile',
//           style: appBarTextStyle,
//         ),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const SeekerSetting()));
//               },
//               icon: const Icon(
//                 Icons.settings,
//                 color: Colors.white,
//               ))
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: _pickProfileImage,
//                   child: CircleAvatar(
//                     radius: 50,
//                     backgroundImage: _profileImageUrl != null
//                         ? FileImage(File(_profileImageUrl!))
//                         : const AssetImage('assets/default_profile_image.png')
//                             as ImageProvider,
//                     child: _profileImageUrl == null
//                         ? const Icon(Icons.add_a_photo)
//                         : null,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text('Name: ${_user.displayName ?? 'N/A'}'),
//               const SizedBox(height: 8),
//               Text('Email: ${_user.email ?? 'N/A'}'),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _locationController,
//                 decoration: const InputDecoration(labelText: 'Location'),
//                 onChanged: (value) {
//                   setState(() {
//                     _location = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _resumeController,
//                 decoration: InputDecoration(
//                   labelText: 'Resume',
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.attach_file),
//                     onPressed: () => _pickFile(_resumeController),
//                   ),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     _resume = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _coverLetterController,
//                 decoration: InputDecoration(
//                   labelText: 'Cover Letter',
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.attach_file),
//                     onPressed: () => _pickFile(_coverLetterController),
//                   ),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     _coverLetter = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _educationController,
//                 decoration: const InputDecoration(labelText: 'Education'),
//                 onChanged: (value) {
//                   setState(() {
//                     _education = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _skillsController,
//                 decoration: const InputDecoration(labelText: 'Skills'),
//                 onChanged: (value) {
//                   setState(() {
//                     _skills = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _languagesController,
//                 decoration: const InputDecoration(labelText: 'Languages'),
//                 onChanged: (value) {
//                   setState(() {
//                     _languages = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _updateProfileData,
//                 child: const Text('Save Profile'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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

class SeekerProfile extends StatefulWidget {
  const SeekerProfile({super.key});

  @override
  SeekerProfileState createState() => SeekerProfileState();
}

class SeekerProfileState extends State<SeekerProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _profileImageUrl;
  String _location = '';
  String _resume = '';
  String _coverLetter = '';
  String _education = '';
  String _skills = '';
  String _languages = '';

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();

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
          _resume = data['resume'] ?? '';
          _coverLetter = data['coverLetter'] ?? '';
          _education = data['education'] ?? '';
          _skills = data['skills'] ?? '';
          _languages = data['languages'] ?? '';

          _locationController.text = _location;
          _resumeController.text = _resume;
          _coverLetterController.text = _coverLetter;
          _educationController.text = _education;
          _skillsController.text = _skills;
          _languagesController.text = _languages;
        });
      }
    }
  }

  Future<void> _updateProfileData() async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).update({
      'profileImageUrl': _profileImageUrl,
      'location': _location,
      'resume': _resume,
      'coverLetter': _coverLetter,
      'education': _education,
      'skills': _skills,
      'languages': _languages,
    });
  }

  Future<void> _pickProfileImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      // Here you can upload the image file to your storage and get the URL
      // For example, using Firebase Storage, and then update _profileImageUrl
      // For simplicity, we are just setting the path to _profileImageUrl
      if (mounted) {
        setState(() {
          _profileImageUrl = imageFile.path;
        });
        _updateProfileData();
      }
    }
  }

  Future<void> _pickFile(TextEditingController controller) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      // Here you can upload the file to your storage and get the URL
      // For simplicity, we are just setting the path to the controller's text
      if (mounted) {
        setState(() {
          controller.text = file.path;
        });
        _updateProfileData();
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _resumeController.dispose();
    _coverLetterController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
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
              ))
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
                        ? const Icon(Icons.add_a_photo)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Name: ${_user!.displayName}'),
              const SizedBox(height: 8),
              Text('Email: ${_user!.email ?? 'N/A'}'),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _resumeController,
                decoration: InputDecoration(
                  labelText: 'Resume',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () => _pickFile(_resumeController),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _resume = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _coverLetterController,
                decoration: InputDecoration(
                  labelText: 'Cover Letter',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () => _pickFile(_coverLetterController),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _coverLetter = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _educationController,
                decoration: const InputDecoration(labelText: 'Education'),
                onChanged: (value) {
                  setState(() {
                    _education = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _skillsController,
                decoration: const InputDecoration(labelText: 'Skills'),
                onChanged: (value) {
                  setState(() {
                    _skills = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _languagesController,
                decoration: const InputDecoration(labelText: 'Languages'),
                onChanged: (value) {
                  setState(() {
                    _languages = value;
                  });
                },
              ),
              const SizedBox(height: 16),
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

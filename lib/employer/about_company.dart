// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:codehunt/auth/login.dart';
// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/employer/emp_data.dart';
// import 'package:codehunt/form_decoration/textstyle.dart';
// import 'package:codehunt/seeker/jobapplication.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AboutCompany extends StatefulWidget {
//   final String jobPostId;
//   final Map<String, dynamic> jobPostData;
//   final String seekerEmail;
//   final String employerEmail;

//   const AboutCompany({
//     super.key,
//     required this.jobPostId,
//     required this.jobPostData,
//     required this.seekerEmail,
//     required this.employerEmail,
//   });

//   @override
//   AboutCompanyState createState() => AboutCompanyState();
// }

// class AboutCompanyState extends State<AboutCompany> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? _employerData;

//   @override
//   void initState() {
//     super.initState();
//     _fetchEmployerData();
//   }

//   Future<void> _fetchEmployerData() async {
//     try {
//       QuerySnapshot querySnapshot = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: widget.employerEmail)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         setState(() {
//           _employerData =
//               querySnapshot.docs.first.data() as Map<String, dynamic>;
//         });
//       }
//     } catch (e) {
//       print('Error fetching employer data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var jobPostData = widget.jobPostData;

//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           'Company Details',
//           style: appBarTextStyle,
//         ),
//         backgroundColor: RegistrationForm.navyColor,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 SingleChildScrollView(
//                   child: Card(
//                     color: Colors.white,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (jobPostData['companyLogo'] != null)
//                                 ClipOval(
//                                   child: Image.network(
//                                     jobPostData['companyLogo'],
//                                     width: 60,
//                                     height: 60,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 '${jobPostData['title']}',
//                                 style: titleTextStyle.copyWith(fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.business,
//                                       color: Colors.grey),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     '${jobPostData['company']}',
//                                     style: postTextStyle,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.calendar_today,
//                                       color: Colors.grey),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     '${jobPostData['postingDate']}',
//                                     style: postTextStyle,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 10),
//                               Divider(thickness: 2.0, color: Colors.grey[300]),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.attach_money,
//                                       color: Colors.grey),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     '${jobPostData['salaryRange']}',
//                                     style: postTextStyle,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.attach_money_rounded,
//                                       color: Colors.grey),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     '${jobPostData['salaryType']}',
//                                     style: postTextStyle,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.location_on,
//                                       color: Colors.grey),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     '${jobPostData['location']}',
//                                     style: postTextStyle,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.type_specimen_sharp,
//                                       color: Colors.grey),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     '${jobPostData['jobType']}',
//                                     style: postTextStyle,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 10),
//                               Divider(thickness: 2.0, color: Colors.grey[300]),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'Job Description',
//                                 style: titleTextStyle.copyWith(fontSize: 18),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 '${jobPostData['description']}',
//                                 style: postTextStyle,
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         ),
//                         Divider(thickness: 2.0, color: Colors.grey[300]),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   if (_employerData!['profileImageUrl'] != null)
//                                     ClipOval(
//                                       child: Image.network(
//                                         _employerData!['profileImageUrl'],
//                                         width: 60,
//                                         height: 60,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   const SizedBox(height: 16),
//                                   Text(
//                                     '${_employerData!['companyName']}',
//                                     style:
//                                         titleTextStyle.copyWith(fontSize: 16),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Email: ${_employerData!['email']}',
//                                     style: postTextStyle,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Website: ${_employerData!['websiteUrl']}',
//                                     style: postTextStyle,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Location: ${_employerData!['location']}',
//                                     style: postTextStyle,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Description: ${_employerData!['description']}',
//                                     style: postTextStyle,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Industry: ${_employerData!['industry']}',
//                                     style: postTextStyle,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Size: ${_employerData!['size']}',
//                                     style: postTextStyle,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Founding Date: ${_employerData!['foundingDate']}',
//                                     style: postTextStyle,
//                                   ),
//                                   const SizedBox(height: 20),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             child: ElevatedButton(
//               onPressed: () {
//                 if (FirebaseAuth.instance.currentUser == null) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const LoginForm(),
//                     ),
//                   );
//                 } else {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => JobApplicationForm(
//                         jobPostId: widget.jobPostId,
//                         jobPostData: widget.jobPostData,
//                         seekerEmail: widget.seekerEmail,
//                       ),
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: RegistrationForm.navyColor,
//               ),
//               child: Text(
//                 'Apply',
//                 style: btnTextStyle,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/employer/emp_data.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/seeker/jobapplication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AboutCompany extends StatefulWidget {
  final String jobPostId;
  final Map<String, dynamic> jobPostData;
  final String seekerEmail;
  final String employerEmail;

  const AboutCompany({
    super.key,
    required this.jobPostId,
    required this.jobPostData,
    required this.seekerEmail,
    required this.employerEmail,
  });

  @override
  AboutCompanyState createState() => AboutCompanyState();
}

class AboutCompanyState extends State<AboutCompany> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _employerData;

  @override
  void initState() {
    super.initState();
    _fetchEmployerData();
  }

  Future<void> _fetchEmployerData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: widget.employerEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _employerData =
              querySnapshot.docs.first.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching employer data: $e')),
      );
      print('Error fetching employer data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var jobPostData = widget.jobPostData;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Company Details',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Card(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (jobPostData['companyLogo'] != null)
                                ClipOval(
                                  child: Image.network(
                                    jobPostData['companyLogo'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                '${jobPostData['title']}',
                                style: titleTextStyle.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.business,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${jobPostData['company']}',
                                    style: postTextStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${jobPostData['postingDate']}',
                                    style: postTextStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(thickness: 2.0, color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${jobPostData['salaryRange']}',
                                    style: postTextStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money_rounded,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${jobPostData['salaryType']}',
                                    style: postTextStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${jobPostData['location']}',
                                    style: postTextStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.type_specimen_sharp,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${jobPostData['jobType']}',
                                    style: postTextStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(thickness: 2.0, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Job Description',
                                style: titleTextStyle.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${jobPostData['description']}',
                                style: postTextStyle,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        Divider(thickness: 2.0, color: Colors.grey[300]),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_employerData != null &&
                                      _employerData!['profileImageUrl'] != null)
                                    ClipOval(
                                      child: Image.network(
                                        _employerData!['profileImageUrl'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  if (_employerData != null)
                                    Text(
                                      '${_employerData!['companyName']}',
                                      style:
                                          titleTextStyle.copyWith(fontSize: 16),
                                    ),
                                  const SizedBox(height: 8),
                                  if (_employerData != null)
                                    Text(
                                      'Email: ${_employerData!['email']}',
                                      style: postTextStyle,
                                    ),
                                  const SizedBox(height: 8),
                                  if (_employerData != null)
                                    Text(
                                      'Website: ${_employerData!['websiteUrl']}',
                                      style: postTextStyle,
                                    ),
                                  const SizedBox(height: 8),
                                  if (_employerData != null)
                                    Text(
                                      'Location: ${_employerData!['location']}',
                                      style: postTextStyle,
                                    ),
                                  const SizedBox(height: 8),
                                  if (_employerData != null)
                                    Text(
                                      'Description: ${_employerData!['description']}',
                                      style: postTextStyle,
                                    ),
                                  const SizedBox(height: 8),
                                  if (_employerData != null)
                                    Text(
                                      'Industry: ${_employerData!['industry']}',
                                      style: postTextStyle,
                                    ),
                                  const SizedBox(height: 8),
                                  if (_employerData != null)
                                    Text(
                                      'Size: ${_employerData!['size']}',
                                      style: postTextStyle,
                                    ),
                                  const SizedBox(height: 8),
                                  if (_employerData != null)
                                    Text(
                                      'Founding Date: ${_employerData!['foundingDate']}',
                                      style: postTextStyle,
                                    ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                if (FirebaseAuth.instance.currentUser == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginForm(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobApplicationForm(
                        jobPostId: widget.jobPostId,
                        jobPostData: widget.jobPostData,
                        seekerEmail: widget.seekerEmail,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RegistrationForm.navyColor,
              ),
              child: Text(
                'Apply',
                style: btnTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

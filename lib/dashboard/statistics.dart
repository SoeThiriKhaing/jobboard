// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class StatisticsPage extends StatefulWidget {
//   final String employerEmail;

//   const StatisticsPage({super.key, required this.employerEmail});

//   @override
//   StatisticsPageState createState() => StatisticsPageState();
// }

// class StatisticsPageState extends State<StatisticsPage>
//     with WidgetsBindingObserver {
//   String searchQuery = '';
//   bool isExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.resumed) {
//       print('App is back in the foreground');
//     } else if (state == AppLifecycleState.paused) {
//       // The app is in the background
//       print('App is in the background');
//     }
//   }

//   Stream<List<QueryDocumentSnapshot>> getJobApplicationsStream(
//       String employerId) {
//     final firestore = FirebaseFirestore.instance;

//     final jobPostsStream = firestore
//         .collection('job_posts')
//         .where('employerId', isEqualTo: employerId)
//         .snapshots();

//     return jobPostsStream.asyncMap((jobPostsSnapshot) async {
//       final jobPostIds = jobPostsSnapshot.docs.map((doc) => doc.id).toList();

//       if (jobPostIds.isEmpty) {
//         return <QueryDocumentSnapshot>[];
//       }

//       try {
//         final jobApplicationsSnapshot = await firestore
//             .collection('job_applications')
//             .where('jobPostId', whereIn: jobPostIds)
//             .get();

//         return jobApplicationsSnapshot.docs;
//       } catch (e) {
//         print('Error retrieving job applications: $e');
//         return <QueryDocumentSnapshot>[]; // Return an empty list on error
//       }
//     });
//   }

//   Future<void> _acceptApplication(Map<String, dynamic> application) async {
//     final email = application['email'];
//     const subject = 'Job Application Accepted';
//     final body =
//         'Dear ${application['name']},\n\nYour job application has been accepted.\n\nBest regards,\nYour Company';

//     final encodedSubject = Uri.encodeComponent(subject);
//     final encodedBody = Uri.encodeComponent(body);
//     final emailUrl = 'mailto:$email?subject=$encodedSubject&body=$encodedBody';

//     try {
//       if (await canLaunch(emailUrl)) {
//         await launch(emailUrl);
//       } else {
//         print('Could not launch URL: $emailUrl');
//       }
//     } catch (e) {
//       print('Exception occurred: $e');
//     }

//     await FirebaseFirestore.instance
//         .collection('job_applications')
//         .doc(application['id'])
//         .update({'status': 'accepted'});
//   }

//   Future<void> _rejectApplication(String documentId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('job_applications')
//           .doc(documentId)
//           .delete();
//       print('Application successfully deleted');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Application rejected and deleted')),
//       );
//     } catch (e) {
//       print('Error deleting application: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting application: $e')),
//       );
//     }
//   }

//   Future<void> _showRejectConfirmationDialog(String documentId) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Rejection'),
//           content:
//               const Text('Are you sure you want to reject this application?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('No'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Yes'),
//               onPressed: () async {
//                 await _rejectApplication(documentId);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       body: Column(
//         children: [
//           // Removed the search bar section
//           Expanded(
//             child: StreamBuilder<List<QueryDocumentSnapshot>>(
//               stream: getJobApplicationsStream(user?.uid ?? ''),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 final jobApplications = snapshot.data ?? [];
//                 final filteredApplications = jobApplications.where((doc) {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final jobTitle = data['jobTitle']?.toLowerCase() ?? '';
//                   return jobTitle.contains(searchQuery);
//                 }).toList();

//                 if (filteredApplications.isEmpty) {
//                   return const Center(
//                     child: Text("No job applications found"),
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: filteredApplications.length,
//                   itemBuilder: (context, index) {
//                     final application = filteredApplications[index].data()
//                         as Map<String, dynamic>;
//                     final documentId = filteredApplications[index].id;

//                     return StatefulBuilder(
//                       builder: (BuildContext context, StateSetter setState) {
//                         return Card(
//                           elevation: 5,
//                           margin: const EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 15),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Name: ${application['name']}',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Text('Email: ${application['email']}'),
//                                 Text('Location: ${application['location']}'),
//                                 Text('Education: ${application['education']}'),
//                                 Text('Skills: ${application['skill']}'),
//                                 Text('Languages: ${application['language']}'),
//                                 const SizedBox(height: 10),
//                                 if (application['resumeUrl'] != null)
//                                   GestureDetector(
//                                     onTap: () async {
//                                       if (await canLaunch(
//                                           application['resumeUrl'])) {
//                                         await launch(application['resumeUrl']);
//                                       } else {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           const SnackBar(
//                                               content: Text(
//                                                   'Could not launch resume URL.')),
//                                         );
//                                       }
//                                     },
//                                     child: const Text(
//                                       'View Resume',
//                                       style: TextStyle(
//                                         color: Colors.blue,
//                                         decoration: TextDecoration.underline,
//                                       ),
//                                     ),
//                                   ),
//                                 const SizedBox(height: 10),
//                                 if (application['coverLetter'] != null)
//                                   GestureDetector(
//                                     onTap: () async {
//                                       if (await canLaunch(
//                                           application['coverLetter'])) {
//                                         await launch(
//                                             application['coverLetter']);
//                                       } else {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           const SnackBar(
//                                               content: Text(
//                                                   'Could not launch cover letter URL.')),
//                                         );
//                                       }
//                                     },
//                                     child: const Text(
//                                       'View Cover Letter',
//                                       style: TextStyle(
//                                         color: Colors.blue,
//                                         decoration: TextDecoration.underline,
//                                       ),
//                                     ),
//                                   ),
//                                 const SizedBox(height: 10),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: ElevatedButton(
//                                         onPressed: () {
//                                           _acceptApplication(application);
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.green,
//                                         ),
//                                         child: const Text('Accept'),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Expanded(
//                                       child: ElevatedButton(
//                                         onPressed: () {
//                                           _showRejectConfirmationDialog(
//                                               documentId);
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.red,
//                                         ),
//                                         child: const Text('Reject'),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

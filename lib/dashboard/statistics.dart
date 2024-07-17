// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/form_decoration/textstyle.dart';

// class StatisticsPage extends StatefulWidget {
//   final String employerEmail;

//   const StatisticsPage({super.key, required this.employerEmail});

//   @override
//   StatisticsPageState createState() => StatisticsPageState();
// }

// class StatisticsPageState extends State<StatisticsPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           'Statistics',
//           style: appBarTextStyle,
//         ),
//         backgroundColor: RegistrationForm.navyColor,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('job_applications')
//             .where('employerEmail', isEqualTo: widget.employerEmail)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final jobApplications = snapshot.data?.docs ?? [];

//           if (jobApplications.isEmpty) {
//             return const Center(
//               child: Text("No job applications found"),
//             );
//           }

//           return ListView.builder(
//             itemCount: jobApplications.length,
//             itemBuilder: (context, index) {
//               var application =
//                   jobApplications[index].data() as Map<String, dynamic>;
//               return Card(
//                 margin: const EdgeInsets.all(8.0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Applicant Name: ${application['name']}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text('Email: ${application['email']}'),
//                       const SizedBox(height: 8),
//                       Text('Phone: ${application['phone']}'),
//                       const SizedBox(height: 8),
//                       Text('Cover Letter: ${application['coverLetter']}'),
//                       const SizedBox(height: 8),
//                       if (application.containsKey('resumeFileName'))
//                         Text('Resume: ${application['resumeFileName']}'),
//                       const SizedBox(height: 8),
//                       Text(
//                           'Application Date: ${application['applicationDate'].toDate()}'),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';

class StatisticsPage extends StatefulWidget {
  final String employerEmail;

  const StatisticsPage({super.key, required this.employerEmail});

  @override
  StatisticsPageState createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Statistics',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('job_applications')
            // .where('employerEmail', isEqualTo: widget.employerEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final jobApplications = snapshot.data?.docs ?? [];

          if (jobApplications.isEmpty) {
            return const Center(
              child: Text("No job applications found"),
            );
          }

          return ListView.builder(
            itemCount: jobApplications.length,
            itemBuilder: (context, index) {
              var application =
                  jobApplications[index].data() as Map<String, dynamic>;
              return Card(
                color: Colors.purple[100],
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (application['profileImageUrl'] != null)
                        Center(
                          child: Image.network(
                            application['profileImageUrl'],
                            height: 100,
                            width: 100,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Applicant Name: ${application['name']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Email: ${application['email']}'),
                      const SizedBox(height: 20),
                      Text('Phone: ${application['phone']}'),
                      const SizedBox(height: 20),
                      Text('Cover Letter: ${application['coverLetter']}'),
                      const SizedBox(height: 20),
                      if (application['resumeFileName'] != null)
                        Text('Resume: ${application['resumeFileName']}'),
                      const SizedBox(height: 20),
                      Text(
                          'Application Date: ${application['applicationDate'].toDate()}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

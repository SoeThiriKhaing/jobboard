import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:codehunt/seeker/seeker_notification.dart'; // Import Seeker Notification Page

class StatisticsPage extends StatefulWidget {
  final String employerEmail;

  const StatisticsPage({super.key, required this.employerEmail});

  @override
  StatisticsPageState createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> {
  Future<void> _acceptApplication(Map<String, dynamic> application) async {
    // Navigate to the Seeker Notification Page
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SeekerNotificationPage(application: application),
    //   ),
    // );
  }

  Future<void> _rejectApplication(String documentId) async {
    await FirebaseFirestore.instance
        .collection('job_applications')
        .doc(documentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
            // .where('userId', isEqualTo: user?.uid)
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

          print("jobApplications length is ${jobApplications[0].id}");

          return ListView.builder(
            itemCount: jobApplications.length,
            itemBuilder: (context, index) {
              var application =
                  jobApplications[index].data() as Map<String, dynamic>;
              var documentId = jobApplications[index].id;

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
                          child: ClipOval(
                            child: Image.network(
                              application['profileImageUrl'],
                              height: 100,
                              width: 100,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
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
                      if (application['resumeUrl'] != null)
                        ElevatedButton(
                          onPressed: () async {
                            final url = application['resumeUrl'];
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: const Text('View Resume'),
                        ),
                      const SizedBox(height: 20),
                      Text(
                          'Application Date: ${application['applicationDate'].toDate()}'),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _acceptApplication(application),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text('Accept'),
                          ),
                          ElevatedButton(
                            onPressed: () => _rejectApplication(documentId),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
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

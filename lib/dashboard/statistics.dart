import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:url_launcher/url_launcher.dart';

class StatisticsPage extends StatefulWidget {
  final String employerEmail;

  const StatisticsPage({super.key, required this.employerEmail});

  @override
  StatisticsPageState createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> {
  Future<void> _acceptApplication(Map<String, dynamic> application) async {
    final email = application['email'];
    const subject = 'Job Application Accepted';
    final body =
        'Dear ${application['name']},\n\nYour job application has been accepted.\n\nBest regards,\nYour Company';

    // Encode the subject and body to ensure proper URL formatting
    final encodedSubject = Uri.encodeComponent(subject);
    final encodedBody = Uri.encodeComponent(body);

    final emailUrl = 'mailto:$email?subject=$encodedSubject&body=$encodedBody';

    print('Email URL: $emailUrl');

    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    } else {
      throw 'Could not launch $emailUrl';
    }
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

              return Expanded(
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 14.0),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (application['profileImageUrl'] != null)
                          ClipOval(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.network(
                                application['profileImageUrl'],
                                fit: BoxFit
                                    .cover, // This ensures the image covers the oval shape
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
                        Text('Location: ${application['location']}'),
                        const SizedBox(height: 20),
                        Text('Education: ${application['education']}'),
                        const SizedBox(height: 20),
                        Text('Skills: ${application['skills']}'),
                        const SizedBox(height: 20),
                        Text('Languages: ${application['language']}'),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}

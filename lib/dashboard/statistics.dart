import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StatisticsPage extends StatefulWidget {
  final String employerEmail;

  const StatisticsPage({super.key, required this.employerEmail});

  @override
  StatisticsPageState createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> {
  // Function to get job applications stream based on employerId
  Stream<List<QueryDocumentSnapshot>> getJobApplicationsStream(
      String employerId) {
    final firestore = FirebaseFirestore.instance;

    // Stream for job posts based on employerId
    final jobPostsStream = firestore
        .collection('job_posts')
        .where('employerId', isEqualTo: employerId)
        .snapshots();

    // Transform job posts stream to job applications stream
    return jobPostsStream.asyncMap((jobPostsSnapshot) async {
      final jobPostIds =
          jobPostsSnapshot.docs.map((doc) => doc.id).toList(); // Use doc.id

      if (jobPostIds.isEmpty) {
        return <QueryDocumentSnapshot>[]; // Return an empty list if no job posts
      }

      // Query job applications based on jobPostIds
      final jobApplicationsSnapshot = await firestore


          .collection('job_applications')
          .where('jobPostId', whereIn: jobPostIds)
          .get();

      return jobApplicationsSnapshot
          .docs; // Return the list of job application documents
    });
  }

  Future<void> _acceptApplication(Map<String, dynamic> application) async {
    final email = application['email'];
    const subject = 'Job Application Accepted';
    final body =
        'Dear ${application['name']},\n\nYour job application has been accepted.\n\nBest regards,\nYour Company';

    // Encode the subject and body to ensure proper URL formatting
    final encodedSubject = Uri.encodeComponent(subject);
    final encodedBody = Uri.encodeComponent(body);
    final emailUrl = 'mailto:$email?subject=$encodedSubject&body=$encodedBody';

    print('Email URL: $emailUrl'); // Debug print

    try {
      if (await canLaunch(emailUrl)) {


        await launch(emailUrl);


      } else {
        print('Could not launch URL: $emailUrl'); // Debug print
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug print
    }
    

    // Update the application status in Firestore
    await FirebaseFirestore.instance


        .collection('job_applications')
        .doc(application['id']) // Ensure you have the document ID
        .update({'status': 'accepted'});
  }

  Future<void> _rejectApplication(String documentId) async {
    await FirebaseFirestore.instance


        .collection('job_applications')
        .doc(documentId)
        .update({'status': 'rejected'});
  }

  Future<void> _showRejectConfirmationDialog(String documentId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Rejection'),
          content:
              const Text('Are you sure you want to reject this application?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await _rejectApplication(documentId);


                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: getJobApplicationsStream(user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final jobApplications = snapshot.data ?? [];

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
              var documentId = jobApplications[index].id;

              return Card(
                elevation: 5,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Applicant Name: ${application['name']}',
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
                              print('Could not launch $url');
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
                            onPressed: () =>
                                _showRejectConfirmationDialog(documentId),
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

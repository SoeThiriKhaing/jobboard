import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/appbarstyle.dart';
import 'package:codehunt/seeker/jobapplication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedJobsPage extends StatelessWidget {
  const SavedJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text('Please log in to see your saved jobs.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Jobs', style: appBarTextStyle),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('saved_jobs')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var savedJobs = snapshot.data!.docs.map((doc) => doc['jobPostId']).toList();

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('job_posts')
                .where(FieldPath.documentId, whereIn: savedJobs)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (doc['companyLogo'] != null)
                            ClipOval(
                              child: Image.network(
                                doc['companyLogo'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 20),
                          Text(
                            'Company Name:${doc['company']}',
                            style: titleTextStyle,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text('JobTitle: ${doc['title']}',
                              style: postTextStyle),
                          const SizedBox(height: 14),
                          Text('SalaryRange: ${doc['salaryRange']}',
                              style: postTextStyle),
                          const SizedBox(height: 14),
                          Text('Job Description: ${doc['description']}',
                              style: postTextStyle),
                          const SizedBox(height: 14),
                          Text('Job Location: ${doc['location']}',
                              style: postTextStyle),
                          const SizedBox(height: 14),
                          Text('Experience Level: ${doc['experienceLevel']}',
                              style: postTextStyle),
                          const SizedBox(height: 14),
                          Text('Required Skills: ${doc['requiredSkills']}',
                              style: postTextStyle),
                          const SizedBox(height: 14),
                          Text('Job Type: ${doc['jobType']}',
                              style: postTextStyle),
                          const SizedBox(height: 14),
                          Text('Posting Date: ${doc['postingDate']}',
                              style: postTextStyle),
                          const SizedBox(height: 14),
                          Text('Ending Date: ${doc['endingDate']}',
                              style: postTextStyle),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () {
                              if (FirebaseAuth.instance.currentUser == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginForm()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobApplicationForm(
                                      jobPostId: doc.id,
                                      jobPostData:
                                          doc.data() as Map<String, dynamic>,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RegistrationForm.navyColor,
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

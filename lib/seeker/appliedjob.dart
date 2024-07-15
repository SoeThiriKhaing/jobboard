import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppliedJobsPage extends StatelessWidget {
  const AppliedJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Applied Jobs",
            style: appBarTextStyle,
          ),
          backgroundColor: RegistrationForm.navyColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text("Please log in to see your applied jobs"),
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
        title: Text('Applied Jobs', style: appBarTextStyle),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('job_applications')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var appliedJobs =
              snapshot.data!.docs.map((doc) => doc['jobPostId']).toList();

          if (appliedJobs.isEmpty) {
            return const Center(
              child: Text('No applied jobs found.'),
            );
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('job_posts')
                .where(FieldPath.documentId, whereIn: appliedJobs)
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

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
          automaticallyImplyLeading: false,
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
            const SizedBox(height: 30.0),
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
                child: const Text(
                  'Sign in',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Applied Jobs', style: appBarTextStyle),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: _buildJobList(context, user.uid),
    );
  }

  Widget _buildJobList(BuildContext context, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('job_applications')
          .where('applicantId', isEqualTo: userId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final appliedJobs = snapshot.data!.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              return data != null && data.containsKey('jobPostId')
                  ? data['jobPostId'] as String
                  : null;
            })
            .whereType<String>()
            .toList();

        if (appliedJobs.isEmpty) {
          return const Center(
            child: Text('No applied jobs found.'),
          );
        }

        return StreamBuilder<QuerySnapshot>(
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
                        Text('Company Name: ${doc['company']}'),
                        const SizedBox(height: 20),
                        Text('Job Title: ${doc['title']}'),
                        const SizedBox(height: 14),
                        Text('Salary Range: ${doc['salaryRange']}'),
                        const SizedBox(height: 14),
                        Text('Job Description: ${doc['description']}'),
                        const SizedBox(height: 14),
                        Text('Job Location: ${doc['location']}'),
                        const SizedBox(height: 14),
                        Text('Experience Level: ${doc['experienceLevel']}'),
                        const SizedBox(height: 14),
                        Text('Required Skills: ${doc['requiredSkills']}'),
                        const SizedBox(height: 14),
                        Text('Job Type: ${doc['jobType']}'),
                        const SizedBox(height: 14),
                        Text('Posting Date: ${doc['postingDate']}'),
                        const SizedBox(height: 14),
                        Text('Ending Date: ${doc['endingDate']}'),
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
    );
  }
}

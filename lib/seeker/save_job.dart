import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/seeker/jobapplication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedJobsPage extends StatefulWidget {
  const SavedJobsPage({super.key});

  @override
  State<SavedJobsPage> createState() => _SavedJobsPageState();
}

class _SavedJobsPageState extends State<SavedJobsPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Saved Jobs",
            style: appBarTextStyle,
          ),
          backgroundColor: RegistrationForm.navyColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text("Please log in to see your saved jobs"),
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

          var savedJobs =
              snapshot.data!.docs.map((doc) => doc['jobPostId']).toList();

          return savedJobs.isEmpty
              ? const Center(
                  child: Text("No Job Post found"),
                )
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('job_posts')
                      .where(FieldPath.documentId, whereIn: savedJobs)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No job post found"),
                      );
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 14.0),
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
                                  '${doc['title']}',
                                  style: titleTextStyle,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text('Company Name: ${doc['company']}',
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
                                Text(
                                    'Experience Level: ${doc['experienceLevel']}',
                                    style: postTextStyle),
                                const SizedBox(height: 14),
                                Text(
                                    'Required Skills: ${doc['requiredSkills']}',
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (FirebaseAuth.instance.currentUser ==
                                            null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginForm()),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  JobApplicationForm(
                                                jobPostId: doc.id,
                                                jobPostData: doc.data()
                                                    as Map<String, dynamic>,
                                                seekerEmail: '',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            RegistrationForm.navyColor,
                                      ),
                                      child: Text(
                                        'Apply',
                                        style: btnTextStyle,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.bookmark_remove),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('saved_jobs')
                                            .where('userId',
                                                isEqualTo: user.uid)
                                            .where('jobPostId',
                                                isEqualTo: doc.id)
                                            .get()
                                            .then((snapshot) {
                                          for (var doc in snapshot.docs) {
                                            doc.reference.delete();
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

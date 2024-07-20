import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/about_company.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
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
                        bool isSaved =
                            true; // Assuming jobs in this list are saved

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutCompany(
                                  jobPostId: doc.id,
                                  jobPostData:
                                      doc.data() as Map<String, dynamic>,
                                  seekerEmail: '',
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 14.0),
                            child: ListTile(
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (doc['companyLogo'] != null)
                                        ClipOval(
                                          child: Image.network(
                                            doc['companyLogo'],
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.bookmark,
                                          color: isSaved
                                              ? Colors.pink
                                              : Colors.grey,
                                        ),
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
                                  const SizedBox(height: 10),
                                  Text(
                                    '${doc['title']}',
                                    style: titleTextStyle,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text('${doc['company']}',
                                      style: postTextStyle),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_money,
                                        color: Colors.grey,
                                      ),
                                      Text('${doc['salaryRange']}',
                                          style: postTextStyle),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey,
                                      ),
                                      Text(
                                          'Posting Date: ${doc['postingDate']}',
                                          style: postTextStyle),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on),
                                      Text(' ${doc['location']}',
                                          style: postTextStyle),
                                    ],
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.all(16),
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

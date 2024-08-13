import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/editjobpost.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePostsPage extends StatefulWidget {
  final String employerEmail;

  const ManagePostsPage({super.key, required this.employerEmail, required String jobPostId});

  @override
  State<ManagePostsPage> createState() => _ManagePostsPageState();
}

class _ManagePostsPageState extends State<ManagePostsPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text("Please log in to see your manage post page"),
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
                      builder: (context) => const LoginForm(),
                    ),
                  );
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('job_posts')
              .where('employerId', isEqualTo: user.uid)
              .where('postedBy', isEqualTo: widget.employerEmail)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var jobPosts = snapshot.data!.docs;

            return jobPosts.isEmpty
                ? const Center(
                    child: Text("No Job Posts found"),
                  )
                : ListView.builder(
                    itemCount: jobPosts.length,
                    itemBuilder: (context, index) {
                      var doc = jobPosts[index];
                      return Card(
                        elevation: 5,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 14.0),
                        child: ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${doc['title']}',
                                style: titleTextStyle,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Salary Range:${doc['salaryRange']}',
                                style: postTextStyle,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Experience Level:${doc['experienceLevel']}',
                                style: postTextStyle,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Required Skills:${doc['requiredSkills']}',
                                style: postTextStyle,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'JobType:${doc['jobType']}',
                                style: postTextStyle,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Posting Date: ${doc['postingDate']}',
                                style: postTextStyle,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: RegistrationForm.navyColor,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditJobPostPage(
                                            employerEmail: widget.employerEmail,
                                            jobPostId: doc.id,
                                            jobPostData: doc.data()
                                                as Map<String, dynamic>,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(doc.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  );
          },
        ),
        // Statistics Tab
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(String jobPostId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this job post?'),
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
                await FirebaseFirestore.instance
                    .collection('job_posts')
                    .doc(jobPostId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

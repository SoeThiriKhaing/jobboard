import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/seeker/jobapplication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SeekerHome extends StatefulWidget {
  const SeekerHome({super.key});

  @override
  SeekerHomeState createState() => SeekerHomeState();
}

class SeekerHomeState extends State<SeekerHome> {
  String searchQuery = '';

  void _saveJob(String jobId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance.collection('saved_jobs').add({
        'jobPostId': jobId,
        'userId': user.uid,
        'savedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to save jobs.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSaved = false;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Find Your Dream IT Job Today',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 5), // changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Search here',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                      ),
                      color: RegistrationForm.navyColor,
                    )),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('job_posts')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  return doc['title']
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery) ||
                      doc['company']
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery);
                }).toList();

                return ListView(
                  children: filteredDocs.map((doc) {
                    return Card(
                      color: Colors.white,
                      margin:const
                          EdgeInsets.symmetric(vertical: 6.0, horizontal: 14.0),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: RegistrationForm.navyColor,
                                  ),
                                  child: Text(
                                    'Apply',
                                    style: btnTextStyle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    _saveJob(doc.id);
                                    setState(() {
                                      isSaved = !isSaved;
                                    });
                                  },
                                  icon: Icon(
                                    isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isSaved ? Colors.pink : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

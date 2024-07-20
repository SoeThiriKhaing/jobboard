import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/about_company.dart'; 
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SeekerHome extends StatefulWidget {
  const SeekerHome({super.key, required this.seekerEmail});

  final String seekerEmail;

  @override
  SeekerHomeState createState() => SeekerHomeState();
}

class SeekerHomeState extends State<SeekerHome> {
  String searchQuery = '';
  Set<String> savedJobIds = Set<String>(); // Track saved jobs

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
  }

  void _loadSavedJobs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final savedJobsSnapshot = await FirebaseFirestore.instance
          .collection('saved_jobs')
          .where('userId', isEqualTo: user.uid)
          .get();
      setState(() {
        savedJobIds = savedJobsSnapshot.docs
            .map((doc) => doc['jobPostId'] as String)
            .toSet();
      });
    }
  }

  void _saveJob(String jobId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance.collection('saved_jobs').add({
        'jobPostId': jobId,
        'userId': user.uid,
        'savedAt': Timestamp.now(),
      }).then((_) {
        setState(() {
          savedJobIds.add(jobId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job saved successfully!')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to save jobs.')),
      );
    }
  }

  void _unsaveJob(String jobId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('saved_jobs')
          .where('jobPostId', isEqualTo: jobId)
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
        setState(() {
          savedJobIds.remove(jobId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job removed from saved list!')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(14.0),
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
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Search here by Job title or Company name',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 15),
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
                    var jobPostData = doc.data() as Map<String, dynamic>?;

                    bool isSaved = savedJobIds.contains(doc.id);

                    return GestureDetector(
                      onTap: () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginForm(),
                            ),
                          );
                        } else if (jobPostData != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AboutCompany(
                                jobPostId: doc.id,
                                jobPostData: jobPostData,
                                seekerEmail: widget.seekerEmail,
                              ),
                            ),
                          );
                        }
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (jobPostData?['companyLogo'] != null)
                                    ClipOval(
                                      child: Image.network(
                                        jobPostData!['companyLogo'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  IconButton(
                                    onPressed: () {
                                      if (isSaved) {
                                        _unsaveJob(doc.id);
                                      } else {
                                        _saveJob(doc.id);
                                      }
                                    },
                                    icon: Icon(
                                      isSaved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color:
                                          isSaved ? Colors.pink : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    '${jobPostData?['title']}',
                                    style: titleTextStyle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Text('${jobPostData?['company']}',
                                      style: postTextStyle),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('${jobPostData?['salaryRange']}',
                                      style: postTextStyle),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('${jobPostData?['postingDate']}',
                                      style: postTextStyle),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('${jobPostData?['location']}',
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
            ),
          ),
        ],
      ),
    );
  }
}

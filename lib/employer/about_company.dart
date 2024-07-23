import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/seeker/jobapplication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AboutCompany extends StatefulWidget {
  final String jobPostId;
  final Map<String, dynamic> jobPostData;
  final String seekerEmail;
  final String employerEmail;

  const AboutCompany({
    super.key,
    required this.jobPostId,
    required this.jobPostData,
    required this.seekerEmail,
    required this.employerEmail,
  });

  @override
  AboutCompanyState createState() => AboutCompanyState();
}

class AboutCompanyState extends State<AboutCompany> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? employerData;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  String? _profileImageUrl;
  String? backgroundImageUrl;

  String? _companyName;
  String? _email;
  String? _websiteUrl;
  String _location = '';
  String _description = '';
  String industry = '';
  String size = '';
  String foundingDate = '';

  bool hasUnsavedChanges = false;
  bool showMore = false;

  var logger = Logger();

  @override
  void initState() {
    super.initState();
    logger.d("REACH ABOUT COMPANY PAGE");

    user = _auth.currentUser;
    _fetchEmployerData();
  }

  Future<void> _fetchEmployerData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();

      if (snapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in snapshot.docs) {
          // Access the data for each user
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          //  String userId = doc.id;
          String? userRole = userData['role'];

          logger.d('User Role: $userRole');

          if (userRole == "Employer") {
            QuerySnapshot snapshot = await _firestore
                .collection('users')
                .where("email", isEqualTo: _email)
                .get();

            if (snapshot.docs.isNotEmpty) {
              for (DocumentSnapshot document in snapshot.docs) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                setState(() {
                  _profileImageUrl = document['profileImageUrl'];
                  _profileImageUrl = data.containsKey('profileImageUrl')
                      ? data['profileImageUrl']
                      : null;
                  backgroundImageUrl = data.containsKey('backgroundImageUrl')
                      ? data['backgroundImageUrl']
                      : null;
                  _companyName = data.containsKey('companyName')
                      ? data['companyName']
                      : '';
                  _email = data.containsKey('email') ? data['email'] : '';
                  _websiteUrl =
                      data.containsKey('websiteUrl') ? data['websiteUrl'] : '';
                  _location =
                      data.containsKey('location') ? data['location'] : '';
                  _description = data.containsKey('description')
                      ? data['description']
                      : '';
                  industry =
                      data.containsKey('industry') ? data['industry'] : '';
                  size = data.containsKey('size') ? data['size'] : '';
                  foundingDate = data.containsKey('foundingDate')
                      ? data['foundingDate']
                      : '';

                  logger.d("Company Name is $_companyName");
                  logger.d("Email  is $_email");
                  logger.d("Website Url is $_websiteUrl");
                  logger.d("Location is $_location");
                  logger.d("Company Desc is $_description");
                });
              }
            }
          } else {
            logger.d("User Role is not our ");
          }
        }
      }
    } catch (e) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching employer data: $e')),
      );
      print('Error fetching employer data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var jobPostData = widget.jobPostData;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Company Details',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (jobPostData['companyLogo'] != null)
                            ClipOval(
                              child: Image.network(
                                jobPostData['companyLogo'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            '${jobPostData['title']}',
                            style: titleTextStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.business, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${jobPostData['company']}',
                                style: postTextStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${jobPostData['postingDate']}',
                                style: postTextStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(thickness: 2.0, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.attach_money,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${jobPostData['salaryRange']}',
                                style: postTextStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.attach_money_rounded,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${jobPostData['salaryType']}',
                                style: postTextStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${jobPostData['location']}',
                                style: postTextStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.type_specimen_sharp,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${jobPostData['jobType']}',
                                style: postTextStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(thickness: 2.0, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Job Description',
                            style: titleTextStyle.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${jobPostData['description']}',
                            style: postTextStyle,
                          ),
                          const SizedBox(height: 20),
                          Divider(thickness: 2.0, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'About Company',
                            style: titleTextStyle.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          if (_profileImageUrl != null)
                            ClipOval(
                              child: Image.network(
                                _profileImageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 16),
                          if (_companyName != null)
                            Text(
                              _companyName!,
                              style: titleTextStyle.copyWith(fontSize: 20),
                            ),
                          const SizedBox(height: 8),
                          if (_email != null)
                            Text(
                              'Email: $_email',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 8),
                          if (_websiteUrl != null)
                            Text(
                              'Website: $_websiteUrl',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 8),
                          if (_location.isNotEmpty)
                            Text(
                              'Location: $_location',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 8),
                          if (_description.isNotEmpty)
                            Text(
                              'Description: $_description',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 8),
                          if (industry.isNotEmpty)
                            Text(
                              'Industry: $industry',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 8),
                          if (size.isNotEmpty)
                            Text(
                              'Size: $size',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 8),
                          if (foundingDate.isNotEmpty)
                            Text(
                              'Founding Date: $foundingDate',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                if (FirebaseAuth.instance.currentUser == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginForm(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobApplicationForm(
                        jobPostId: widget.jobPostId,
                        jobPostData: widget.jobPostData,
                        seekerEmail: widget.seekerEmail,
                        employerEmail: widget.employerEmail,
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
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Fetch the user document for the currently logged-in user
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .where('role', isEqualTo: 'Employer')
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _profileImageUrl = data['profileImageUrl'] ?? null;
          backgroundImageUrl = data['backgroundImageUrl'] ?? null;
          _companyName = data['companyName'] ?? '';
          _email = data['email'] ?? '';
          _websiteUrl = data['websiteUrl'] ?? '';
          _location = data['location'] ?? '';
          _description = data['description'] ?? '';
          industry = data['industry'] ?? '';
          size = data['size'] ?? '';
          foundingDate = data['foundingDate'] ?? '';

          logger.d("Company Name is $_companyName");
          logger.d("Email is $_email");
          logger.d("Website Url is $_websiteUrl");
          logger.d("Location is $_location");
          logger.d("Company Desc is $_description");
        });
      } else {
        logger.d("No employer data found for the current user.");
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
                            style: titleTextStyle.copyWith(
                                fontSize: 18, color: Colors.purple),
                          ),
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 20),
                          if (_description.isNotEmpty)
                            Text(
                              'Description: $_description',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 12),
                          if (industry.isNotEmpty)
                            Text(
                              'Industry: $industry',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 12),
                          if (size.isNotEmpty)
                            Text(
                              'Size: $size',
                              style: postTextStyle,
                            ),
                          const SizedBox(height: 12),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to job application page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobApplicationForm(
                      jobPostId: widget.jobPostId,
                      jobPostData: widget.jobPostData,
                      seekerEmail: widget.seekerEmail,
                      employerEmail: widget.employerEmail,
                      jobPostTitle: jobPostData['title'],
                    ),
                  ),
                );
              },
              child: Text('Apply Now'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: RegistrationForm.navyColor,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

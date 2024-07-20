import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/seeker/jobapplication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AboutCompany extends StatefulWidget {
  final String jobPostId;
  final Map<String, dynamic> jobPostData;
  final String seekerEmail;

  const AboutCompany({
    super.key,
    required this.jobPostId,
    required this.jobPostData,
    required this.seekerEmail,
  });

  @override
  AboutCompanyState createState() => AboutCompanyState();
}

class AboutCompanyState extends State<AboutCompany> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                child: Column(
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
                          const SizedBox(
                            height: 20,
                          ),
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
                                        builder: (context) => const LoginForm(),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            JobApplicationForm(
                                          jobPostId: widget.jobPostId,
                                          jobPostData: widget.jobPostData,
                                          seekerEmail: widget.seekerEmail,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

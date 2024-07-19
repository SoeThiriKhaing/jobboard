import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/managepost.dart';
import 'package:codehunt/dashboard/company_profile.dart';
import 'package:codehunt/dashboard/statistics.dart';
import 'package:codehunt/form_decoration/textstyle.dart';

class EmployerHomePage extends StatefulWidget {
  final String employerEmail;

  const EmployerHomePage({super.key, required this.employerEmail});

  @override
  EmployerHomePageState createState() => EmployerHomePageState();
}

class EmployerHomePageState extends State<EmployerHomePage> {
  late Future<int> _totalJobPostsFuture;

  @override
  void initState() {
    super.initState();
    _totalJobPostsFuture = _fetchTotalJobPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Employer Dashboard',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<int>(
            future: _totalJobPostsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final totalJobPosts = snapshot.data ?? 0;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = (constraints.maxWidth / 200).floor();
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return _buildCard(index, context, totalJobPosts);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index, BuildContext context, int totalJobPosts) {
    switch (index) {
      case 0:
        return _buildJobPostCard(context, totalJobPosts);
      case 1:
        return _buildCompanyProfileCard(context);
      case 2:
        return _buildStatisticsCard(context);
      default:
        return Card(
          color: Colors.grey[200],
          elevation: 3,
          child: Center(
            child: Text('Grid Item $index'),
          ),
        );
    }
  }

  Widget _buildJobPostCard(BuildContext context, int totalJobPosts) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ManagePostsPage(employerEmail: widget.employerEmail),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow.shade700, Colors.yellow.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job Postings',
                style: dashTitleStyle.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Center(
                  child: Text('Total job postings: $totalJobPosts',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManagePostsPage(
                            employerEmail: widget.employerEmail),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                  child: Center(
                    child: Text(
                      'View Jobs',
                      style: dashTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyProfileCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CompanyProfilePage(employerEmail: widget.employerEmail),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Company Profile',
                style: dashTitleStyle.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 25),
              const Center(
                  child: Text('Edit and view your company profile',
                      style: TextStyle(color: Colors.white))),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyProfilePage(
                            employerEmail: widget.employerEmail),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Edit Profile',
                    style: dashTextStyle.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StatisticsPage(employerEmail: widget.employerEmail),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: dashTitleStyle.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 44),
              const Center(
                  child: Text('View application and hiring statistics',
                      style: TextStyle(color: Colors.white))),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StatisticsPage(employerEmail: widget.employerEmail),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'View Status',
                    style: dashTextStyle.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _fetchTotalJobPosts({int retryCount = 5}) async {
    final user = FirebaseAuth.instance.currentUser;
    int attempt = 0;
    while (attempt < retryCount) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('job_posts')
            .where('jobPostId', isEqualTo: user?.uid)
            .where('postedBy', isEqualTo: widget.employerEmail)
            .get();
        return querySnapshot.size;
      } on FirebaseException catch (e) {
        if (e.code == 'unavailable') {
          attempt++;
          final backoffDelay = Duration(seconds: 2 * attempt);
          await Future.delayed(backoffDelay);
        } else {
          rethrow;
        }
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
      message: 'The service is currently unavailable after multiple retries.',
    );
  }
}

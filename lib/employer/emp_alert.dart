import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/auth/register.dart';

class EmpAlert extends StatefulWidget {
  final String employerEmail;

  const EmpAlert({super.key, required this.employerEmail});

  @override
  EmpAlertState createState() => EmpAlertState();
}

class EmpAlertState extends State<EmpAlert>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<DocumentSnapshot>> _allSeekersFuture;
  late Future<List<DocumentSnapshot>> _acceptedSeekersFuture;
  late Future<List<DocumentSnapshot>> _rejectedSeekersFuture;
  String? _selectedJobTitle;

  final List<String> jobTitles = [
    'Software Engineer',
    'Web Developer',
    'Systems Analyst',
    'Network Administrator',
    'Database Administrator',
    'IT Support Specialist',
    'Cybersecurity Analyst',
    'DevOps Engineer',
    'Front-End Developer',
    'Back-End Developer',
    'Full Stack Developer',
    'Cloud Engineer',
    'IT Project Manager',
    'Technical Support Engineer',
    'Data Scientist',
    'Machine Learning Engineer',
    'Business Intelligence Analyst',
    'Systems Engineer',
    'QA Engineer (Quality Assurance)',
    'UX/UI Designer'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchSeekersData();
  }

  void _fetchSeekersData() {
    setState(() {
      _allSeekersFuture = _fetchSeekers();
      _acceptedSeekersFuture = _fetchSeekersByStatus('Accepted');
      _rejectedSeekersFuture = _fetchSeekersByStatus('Rejected');
    });
  }

  Future<List<DocumentSnapshot>> _fetchSeekers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }
    try {
      final jobPostsSnapshot = await FirebaseFirestore.instance
          .collection('job_posts')
          .where('employerId', isEqualTo: currentUser.uid)
          .get();
      final jobPostIds = jobPostsSnapshot.docs.map((doc) => doc.id).toList();
      final seekersSnapshot = await FirebaseFirestore.instance
          .collection('job_applications')
          .where('jobPostId', whereIn: jobPostIds)
          .get();
      return seekersSnapshot.docs;
    } catch (e) {
      print("Error fetching seekers: $e");
      return [];
    }
  }

  Future<List<DocumentSnapshot>> _fetchSeekersByStatus(String status) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }
    try {
      final jobPostsSnapshot = await FirebaseFirestore.instance
          .collection('job_posts')
          .where('employerId', isEqualTo: currentUser.uid)
          .get();
      final jobPostIds = jobPostsSnapshot.docs.map((doc) => doc.id).toList();
      final seekersSnapshot = await FirebaseFirestore.instance
          .collection('job_applications')
          .where('jobPostId', whereIn: jobPostIds)
          .where('submittedBy', isEqualTo: currentUser.email)
          .where('status', isEqualTo: status)
          .get();
      return seekersSnapshot.docs;
    } catch (e) {
      print("Error fetching seekers by status: $e");
      return [];
    }
  }

  Future<void> _updateStatus(String applicationId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('job_applications')
          .doc(applicationId)
          .update({'status': status});
      _fetchSeekersData();
      // Update tabController index
      if (status == 'Accepted') {
        _tabController.animateTo(1);
      } else if (status == 'Rejected') {
        _tabController.animateTo(2);
      }
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  Future<void> _showJobApplicationForm(BuildContext context,
      Map<String, dynamic>? data, String applicationId) async {
    // Fetch the application data
    final applicationData = await FirebaseFirestore.instance
        .collection('job_applications')
        .doc(applicationId)
        .get();

    final application = applicationData.data();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Job Application Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (application?['profileImageUrl'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      application!['profileImageUrl'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 10),
                Text('Name: ${application?['name'] ?? 'No data'}'),
                Text('Education: ${application?['education'] ?? 'No data'}'),
                Text('Skills: ${application?['skill'] ?? 'No data'}'),
                Text('Location: ${application?['location'] ?? 'No data'}'),
                const SizedBox(height: 10),
                Text('Cover Letter:'),
                Text(application?['coverLetter'] ?? 'No data'),
                const SizedBox(height: 10),
                Text('Resume:'),
                Text(application?['resume'] ?? 'No data'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Saved Seekers',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'All Seekers'),
                Tab(text: 'Accepted'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSeekersList(_allSeekersFuture),
          _buildSeekersList(_acceptedSeekersFuture),
          _buildSeekersList(_rejectedSeekersFuture),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: RegistrationForm.navyColor,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Filter Seekers by Job Title'),
                content: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedJobTitle,
                  hint: const Text('Select Job Title'),
                  items: jobTitles.map((title) {
                    return DropdownMenuItem<String>(
                      value: title,
                      child: Text(title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedJobTitle = value;
                    });
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSeekersList(Future<List<DocumentSnapshot>> seekersFuture) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: seekersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final seekers = snapshot.data ?? [];

        return ListView(
          children: seekers.map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            final applicationId = doc.id;

            return Card(
              color: Colors.white,
              elevation: 5,
              margin:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 14.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  children: [
                    if (data?['profileImageUrl'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          data!['profileImageUrl'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${data?['name'] ?? 'No data'}'),
                          Text('Education: ${data?['education'] ?? 'No data'}'),
                          Text('Skills: ${data?['skill'] ?? 'No data'}'),
                          Text('Location: ${data?['location'] ?? 'No data'}'),
                          const SizedBox(height: 8),
                          Text(
                              'Cover Letter: ${data?['coverLetter'] ?? 'No data'}'),
                          Text('Resume: ${data?['resume'] ?? 'No data'}'),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () =>
                    _showJobApplicationForm(context, data, applicationId),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Accepted') {
                      _updateStatus(applicationId, 'Accepted');
                    } else if (value == 'Rejected') {
                      _updateStatus(applicationId, 'Rejected');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'Accepted',
                      child: Text('Accept'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Rejected',
                      child: Text('Reject'),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

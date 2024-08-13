import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/employer/job_app_detail.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchSeekersData();
  }

  void _fetchSeekersData() {
    setState(() {
      _allSeekersFuture = _fetchAllSeekers();
      _acceptedSeekersFuture = _fetchSeekersByStatus('Accepted');
      _rejectedSeekersFuture = _fetchSeekersByStatus('Rejected');
    });
  }

  Future<List<DocumentSnapshot>> _fetchAllSeekers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }
    try {
      final jobPostsSnapshot = await FirebaseFirestore.instance
          .collection('job_posts')
          .where('employerId', isEqualTo: user.uid)
          .get();
      final jobPostIds = jobPostsSnapshot.docs.map((doc) => doc.id).toList();

      final seekersSnapshot = await FirebaseFirestore.instance
          .collection('job_applications')
          .where('jobPostId', whereIn: jobPostIds)
          .get();

      final savedSeekersSnapshot = await FirebaseFirestore.instance
          .collection('savedSeekers')
          .where('userId', isEqualTo: user.uid)
          .get();

      final allSeekers = [
        ...seekersSnapshot.docs,
        ...savedSeekersSnapshot.docs
      ];
      return allSeekers;
    } catch (e) {
      print("Error fetching all seekers: $e");
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
      _fetchSeekersData(); // Refresh the data for all tabs
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

  @override
  Widget build(BuildContext context) {
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
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data?['name'] ?? 'No name'),
                          Text('Education: ${data?['education'] ?? 'No data'}'),
                          Text('Skills: ${data?['skill'] ?? 'No data'}'),
                          Text('Location: ${data?['location'] ?? 'No data'}'),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    _updateStatus(applicationId, value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Accepted',
                      child: Text('Accept'),
                    ),
                    const PopupMenuItem(
                      value: 'Rejected',
                      child: Text('Reject'),
                    ),
                  ],
                ),
                onTap: () {
                  _navigateToJobAppDetail(context, data, applicationId);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _navigateToJobAppDetail(
      BuildContext context, Map<String, dynamic>? data, String applicationId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobAppDetail(
          seekerId: applicationId,
          applicantId: data?['applicantId'] ?? '',
          applicationId: applicationId,
        ),
      ),
    );
  }
}

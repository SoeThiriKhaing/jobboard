import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/register.dart';
import 'package:flutter/material.dart';

class ManageJobPostsPage extends StatefulWidget {
  const ManageJobPostsPage({super.key});

  @override
  ManageJobPostsPageState createState() => ManageJobPostsPageState();
}

class ManageJobPostsPageState extends State<ManageJobPostsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCompany;
  final Map<String, bool> _expandedJobPosts = {};

  Future<void> _deleteJobPost(String jobPostId) async {
    try {
      await _firestore.collection('job_posts').doc(jobPostId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting job post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _selectedCompany != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedCompany = null;
                  });
                },
              )
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _selectedCompany == null
              ? 'Manage Job Posts'
              : 'Posts for $_selectedCompany',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor:
            RegistrationForm.navyColor, // Change to your desired color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('job_posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No job posts found.'));
          }

          final jobPosts = snapshot.data!.docs;
          final Map<String, List<DocumentSnapshot>> groupedByCompany = {};
          for (var jobPost in jobPosts) {
            final company = jobPost['company'];
            if (!groupedByCompany.containsKey(company)) {
              groupedByCompany[company] = [];
            }
            groupedByCompany[company]!.add(jobPost);
          }

          if (_selectedCompany == null) {
            // Display grid view of companies
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: groupedByCompany.keys.length,
              itemBuilder: (context, index) {
                final company = groupedByCompany.keys.elementAt(index);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCompany = company;
                    });
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          company,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            final posts = groupedByCompany[_selectedCompany]!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final jobPost = posts[index];
                final jobPostId = jobPost.id;
                final jobTitle = jobPost['title'];
                final jobDescription = jobPost['description'];
                final salaryRange = jobPost['salaryRange'] ?? 'Not specified';
                final experienceLevel =
                    jobPost['experienceLevel'] ?? 'Not specified';
                final requiredSkills =
                    jobPost['requiredSkills'] ?? 'Not specified';
                final jobType = jobPost['jobType'] ?? 'Not specified';
                final postingDate = jobPost['postingDate'] ?? 'Not specified';
                final companyLogo =
                    jobPost['companyLogo'] ?? ''; // Add this line

                // Initialize the expanded state for each job post
                if (!_expandedJobPosts.containsKey(jobPostId)) {
                  _expandedJobPosts[jobPostId] = false;
                }

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(8),
                  elevation: 4,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            companyLogo.isNotEmpty
                                ? Image.network(
                                    companyLogo,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 8),
                            Text(jobTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Salary Range: $salaryRange'),
                            Text('Experience Level: $experienceLevel'),
                            Text('Job Type: $jobType'),
                            Text('Posting Date: $postingDate'),
                            const SizedBox(height: 8),
                            if (_expandedJobPosts[jobPostId]!)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Required Skills: $requiredSkills'),
                                  const SizedBox(height: 8),
                                  Text(jobDescription,
                                      overflow: TextOverflow.visible),
                                ],
                              ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _expandedJobPosts[jobPostId] =
                                      !_expandedJobPosts[jobPostId]!;
                                });
                              },
                              child: Text(
                                _expandedJobPosts[jobPostId]!
                                    ? 'See Less'
                                    : 'See More',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                      'Are you sure you want to delete this job post?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              await _deleteJobPost(jobPostId);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

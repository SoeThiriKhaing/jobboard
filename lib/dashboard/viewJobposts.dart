import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Viewjobposts extends StatelessWidget {
  final String employerEmail;

  const Viewjobposts({super.key, required this.employerEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Job Posts'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('job_posts')
              .where('postedBy', isEqualTo: employerEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final jobPosts = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: jobPosts.length,
              itemBuilder: (context, index) {
                final jobPost = jobPosts[index];
                return ListTile(
                  title: Text(jobPost['title']),
                  subtitle: Text(jobPost['description']),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

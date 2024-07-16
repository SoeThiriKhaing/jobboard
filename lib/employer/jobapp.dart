import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JobApplicationsPage extends StatelessWidget {
  final String employerEmail;

  const JobApplicationsPage({super.key, required this.employerEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Applications'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('job_applications')
              .where('employerEmail', isEqualTo: employerEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final applications = snapshot.data?.docs ?? [];
            if (applications.isEmpty) {
              return const Center(child: Text('No applications found.'));
            }
            return ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                return ListTile(
                  title: Text(application['name']),
                  subtitle: Text('Email: ${application['email']}'),
                  onTap: () {
                    // Optionally, you can add more detailed view
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

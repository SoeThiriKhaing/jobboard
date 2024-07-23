import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobseekerDetailPage extends StatelessWidget {
  final String jobseekerId;

  const JobseekerDetailPage({super.key, required this.jobseekerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Jobseeker Details',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(jobseekerId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Card(
              color: Colors.white,
              elevation: 4, // Adjust the elevation for shadow effect
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12.0), // Adjust the border radius
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        data['profileImageUrl'] != null
                            ? Image.network(
                                data['profileImageUrl'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const Image(
                                image: AssetImage(
                                    'assets/default_profile_image.png'),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                        const SizedBox(width: 16),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['fullName'] ?? 'No Name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${data['education'] ?? 'No data'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.school, // Use any icon you prefer
                          color: RegistrationForm.navyColor,
                          size: 20, // Adjust size as needed
                        ),
                        const SizedBox(width: 8), // Space between icon and text
                        Expanded(
                          child: Text(
                            '${data['education'] ?? 'No data'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.code, // Use any icon you prefer
                          color: RegistrationForm.navyColor,
                          size: 20, // Adjust size as needed
                        ),
                        const SizedBox(width: 8), // Space between icon and text
                        Expanded(
                          child: Text(
                            '${data['skills'] ?? 'No data'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Languages: ${data['languages'] ?? 'No data'}'),
                    const SizedBox(height: 20),
                    Text('Location: ${data['location'] ?? 'No data'}'),
                    const SizedBox(height: 20),
                    Text('Description: ${data['description'] ?? 'No data'}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';

class JobAppDetail extends StatelessWidget {
  final String seekerId;
  final String applicantId;
  final String applicationId;

  const JobAppDetail({
    Key? key,
    required this.seekerId,
    required this.applicantId,
    required this.applicationId,
  }) : super(key: key);

  Future<void> _invite(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Job Application Invitation',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.platformDefault);
      } else {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      print('Email URI: $emailUri');
      print('Scheme: ${emailUri.scheme}');
      print('Path: ${emailUri.path}');
      print('Query: ${emailUri.query}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: RegistrationForm.navyColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Job Application Details',
          style: appBarTextStyle,
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('job_applications')
            .doc(applicationId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 14.0),
                      color: Colors.white,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['profileImageUrl'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  data['profileImageUrl'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              'Name: ${data['name'] ?? 'No name'}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Education: ${data['education'] ?? 'No data'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Skills: ${data['skill'] ?? 'No data'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Location: ${data['location'] ?? 'No data'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Application Status: ${data['status'] ?? 'No status'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Description:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['description'] ?? 'No data',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Pop the current route
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              const Size(double.infinity, 50), // Full width
                        ),
                        child: Text(
                          'Cancel',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final email = data['email'] ?? '';
                          _invite(email);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              RegistrationForm.navyColor, // Button color
                          minimumSize:
                              const Size(double.infinity, 50), // Full width
                        ),
                        child: Text(
                          'Apply',
                          style: btnTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

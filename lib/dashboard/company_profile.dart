import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyProfilePage extends StatelessWidget {
  final String employerEmail;

  const CompanyProfilePage({super.key, required this.employerEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: RegistrationForm.navyColor,
        title: Text(
          'Company Profile',
          style: appBarTextStyle,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('companies')
            .doc(employerEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final companyProfile = snapshot.data?.data() as Map<String, dynamic>?;
          if (companyProfile == null) {
            return const Center(child: Text('No company profile found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Name: ${companyProfile['name']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text('Email: ${companyProfile['email']}'),
                const SizedBox(height: 10),
                Text('Location: ${companyProfile['location']}'),
                const SizedBox(height: 10),
                Text('Description: ${companyProfile['description']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

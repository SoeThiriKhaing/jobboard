import 'package:cloud_firestore/cloud_firestore.dart';

class Employer {
  final String id;
  final String profileImage;
  final String companyEmail;
  final String phoneNumber;
  final String location;
  final String jobDescription;

  Employer({
    required this.id,
    required this.profileImage,
    required this.companyEmail,
    required this.phoneNumber,
    required this.location,
    required this.jobDescription,
  });

  factory Employer.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Employer(
      id: doc.id,
      profileImage: data['profileImage'] ?? '', // Provide a default value
      companyEmail: data['companyEmail'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      location: data['location'] ?? '',
      jobDescription: data['jobDescription'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileImage': profileImage,
      'companyEmail': companyEmail,
      'phoneNumber': phoneNumber,
      'location': location,
      'jobDescription': jobDescription,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Employer {
  final String id;
  final String profileImage;
  final String companyName;
  final String companyEmail;
  final String websiteUrl;
  final String industry;
  final String companySize;
  final String foundingDate;
  final String location;
  final String jobDescription;

  Employer({
    required this.id,
    required this.profileImage,
    required this.companyEmail,
    required this.companyName,
    required this.foundingDate,
    required this.companySize,
    required this.industry,
    required this.websiteUrl,
    required this.location,
    required this.jobDescription,
  });

  factory Employer.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Employer(
      id: doc.id,
      profileImage: data['profileImage'] ?? '',
      companyName: data['companyName'] ?? '',
      companyEmail: data['companyEmail'] ?? '',
      websiteUrl: data['websiteUrl'] ?? '',
      companySize: data['companySize'] ?? '',
      foundingDate: data['Foundingdate'] ?? '',
      location: data['location'] ?? '',
      jobDescription: data['jobDescription'] ?? '',
      industry: data['industry'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileImage': profileImage,
      'companyEmail': companyEmail,
      'companyName': companyName,
      'websiteUrl': websiteUrl,
      'industry': industry,
      'companySize': companySize,
      'foundingDate': foundingDate,
      'location': location,
      'jobDescription': jobDescription,
    };
  }
}

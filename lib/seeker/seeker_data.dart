import 'package:cloud_firestore/cloud_firestore.dart';

class Jobseeker {
  final String id;
  final String profileImage;

  final String phoneNumber;
  final String location;


  Jobseeker(
   {
    required this.id,
    required this.profileImage,
    required this.phoneNumber,
    required this.location,

  });

  factory Jobseeker.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Jobseeker(
      id: doc.id,
      profileImage: data['profileImage'] ?? '',
 
      phoneNumber: data['phoneNumber'] ?? '',
      location: data['location'] ?? '',
   
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'location': location,

    };
  }
}

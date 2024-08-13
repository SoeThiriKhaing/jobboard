// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/form_decoration/textstyle.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CompanyDetail extends StatelessWidget {
//   final String employerId;

//   const CompanyDetail({super.key, required this.employerId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           'Company Details',
//           style: appBarTextStyle,
//         ),
//         backgroundColor: RegistrationForm.navyColor,
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('users')
//             .doc(employerId)
//             .get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('No data available'));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>;

//           return SingleChildScrollView(
//             child: Card(
//               color: Colors.white,
//               elevation: 4, // Adjust the elevation for shadow effect
//               shape: RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(12.0), // Adjust the border radius
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Background Image Section
//                     if (data['backgroundImageUrl'] != null)
//                       Container(
//                         width: double.infinity,
//                         height: 200,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                             image: NetworkImage(data['backgroundImageUrl']),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),

//                     const SizedBox(height: 16.0),

//                     Row(
//                       children: [
//                         data['profileImageUrl'] != null
//                             ? Image.network(
//                                 data['profileImageUrl'],
//                                 width: 60,
//                                 height: 60,
//                                 fit: BoxFit.cover,
//                               )
//                             : const Image(
//                                 image: AssetImage(
//                                     'assets/default_profile_image.png'),
//                                 width: 60,
//                                 height: 60,
//                                 fit: BoxFit.cover,
//                               ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 data['companyName'] ?? 'No Name',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 '${data['email'] ?? 'No data'}',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 14),
//                               ),
//                               Text(
//                                 data['websiteUrl'] ?? 'No Website URL',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 data['industry'] ?? 'No Industry',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 data['description'] ?? 'No Description',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 data['location'] ?? 'No Location',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 data['size'] ?? 'No Size',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 data['foundingDate'] ?? 'No Founding Date',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

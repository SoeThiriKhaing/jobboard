import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/managepost.dart';
import 'package:codehunt/dashboard/statistics.dart';
import 'package:codehunt/form_decoration/textstyle.dart';

class EmployerHomePage extends StatefulWidget {
  final String employerEmail;

  const EmployerHomePage({super.key, required this.employerEmail});

  @override
  EmployerHomePageState createState() => EmployerHomePageState();
}

class EmployerHomePageState extends State<EmployerHomePage> {
  late Future<int> _totalJobPostsFuture;

  @override
  void initState() {
    super.initState();
    _totalJobPostsFuture = _fetchTotalJobPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Employer Dashboard',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<int>(
            future: _totalJobPostsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final totalJobPosts = snapshot.data ?? 0;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 3 / 2,
                children: [
                  _buildJobPostCard(context, totalJobPosts),
                  _buildStatisticsCard(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildJobPostCard(BuildContext context, int totalJobPosts) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ManagePostsPage(employerEmail: widget.employerEmail),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow.shade700, Colors.yellow.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text('Total job posts: $totalJobPosts',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StatisticsPage(employerEmail: widget.employerEmail),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('View application and hiring statistics',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _fetchTotalJobPosts({int retryCount = 5}) async {
    final user = FirebaseAuth.instance.currentUser;
    int attempt = 0;
    while (attempt < retryCount) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('job_posts')
            .where('jobPostId', isEqualTo: user?.uid)
            .where('postedBy', isEqualTo: widget.employerEmail)
            .get();
        return querySnapshot.size;
      } on FirebaseException catch (e) {
        if (e.code == 'unavailable') {
          attempt++;
          final backoffDelay = Duration(seconds: 2 * attempt);
          await Future.delayed(backoffDelay);
        } else {
          rethrow;
        }
      }
    }
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
      message: 'The service is currently unavailable after multiple retries.',
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:codehunt/auth/login.dart';
// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/form_decoration/textstyle.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class EmployerHomePage extends StatefulWidget {
//   final String employerEmail;

//   const EmployerHomePage({super.key, required this.employerEmail});

//   @override
//   EmployerHomePageState createState() => EmployerHomePageState();
// }

// class EmployerHomePageState extends State<EmployerHomePage> {
//   String searchQuery = '';
//   late Future<List<DocumentSnapshot>> _seekersFuture;

//   @override
//   void initState() {
//     super.initState();
//     _seekersFuture = _fetchSeekers();
//   }

//   Future<List<DocumentSnapshot>> _fetchSeekers() async {
//     try {
//       final querySnapshot =
//           await FirebaseFirestore.instance.collection('seekers').get();
//       return querySnapshot.docs;
//     } catch (e) {
//       print("Error fetching seekers: $e");
//       return [];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Find',
//           style: appBarTextStyle,
//         ),
//         backgroundColor: RegistrationForm.navyColor,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(14.0),
//             child: Container(
//               width: screenWidth,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 decoration: InputDecoration(
//                     hintText: 'Search by Seeker name or skill',
//                     hintStyle:
//                         const TextStyle(color: Colors.grey, fontSize: 15),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 15.0, horizontal: 20),
//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           // Refresh the seekers list based on the search query
//                           _seekersFuture = _fetchSeekers();
//                         });
//                       },
//                       icon: const Icon(
//                         Icons.search,
//                       ),
//                       color: RegistrationForm.navyColor,
//                     )),
//                 onChanged: (value) {
//                   setState(() {
//                     searchQuery = value.toLowerCase();
//                   });
//                 },
//               ),
//             ),
//           ),
//           Expanded(
//             child: FutureBuilder<List<DocumentSnapshot>>(
//               future: _seekersFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 final seekers = snapshot.data ?? [];
//                 final filteredSeekers = seekers.where((doc) {
//                   final data = doc.data() as Map<String, dynamic>?;
//                   final name = data?['name']?.toString().toLowerCase() ?? '';
//                   final skills = (data?['skills'] as List<dynamic>?)
//                           ?.map((skill) => skill.toString().toLowerCase())
//                           .toList() ??
//                       [];

//                   return name.contains(searchQuery) ||
//                       skills.any((skill) => skill.contains(searchQuery));
//                 }).toList();

//                 return ListView(
//                   children: filteredSeekers.map((doc) {
//                     final data = doc.data() as Map<String, dynamic>?;

//                     return Card(
//                       margin: const EdgeInsets.symmetric(
//                           vertical: 6.0, horizontal: 14.0),
//                       child: ListTile(
//                         title: Text(data?['name'] ?? 'No Name'),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (data?['profileImage'] != null)
//                               ClipOval(
//                                 child: Image.network(
//                                   data!['profileImage'],
//                                   width: 60,
//                                   height: 60,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             const SizedBox(height: 10),
//                             Text(
//                                 'Skills: ${data?['skills']?.join(', ') ?? 'No Skills'}'),
//                             const SizedBox(height: 8),
//                             Text('Email: ${data?['email'] ?? 'No Email'}'),
//                             const SizedBox(height: 14),
//                           ],
//                         ),
//                         contentPadding: const EdgeInsets.all(16),
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

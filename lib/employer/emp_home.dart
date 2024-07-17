import 'package:codehunt/dashboard/management_tool.dart';
import 'package:codehunt/dashboard/statistics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/managepost.dart';
import 'package:codehunt/dashboard/company_profile.dart';
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
      body: Padding(
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
            return SingleChildScrollView(
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _buildJobPostCard(context, totalJobPosts);
                        case 1:
                          return _buildCompanyProfileCard(context);
                        case 2:
                          return _buildStatisticsCard(context);
                        case 3:
                          return _buildManagementToolsCard(context);
                        default:
                          return Card(
                            color: Colors.grey[200],
                            elevation: 3,
                            child: Center(
                              child: Text('Grid Item $index'),
                            ),
                          );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJobPostCard(BuildContext context, int totalJobPosts) {
    return Card(
      color: Colors.yellow,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Postings',
              style: dashTitleStyle,
            ),
            const SizedBox(height: 10),
            Center(child: Text('Total job postings: $totalJobPosts')),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManagePostsPage(employerEmail: widget.employerEmail),
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    'View Jobs',
                    style: dashTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyProfileCard(BuildContext context) {
    return Card(
      color: Colors.lightBlueAccent,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Profile',
              style: dashTitleStyle,
            ),
            const SizedBox(height: 25),
            const Center(child: Text('Edit and view your company profile')),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyProfilePage(
                          employerEmail: widget.employerEmail),
                    ),
                  );
                },
                child: Text(
                  'Edit Profile',
                  style: dashTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return Card(
      color: Colors.green,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: dashTitleStyle,
            ),
            const SizedBox(height: 44),
            const Center(child: Text('View application and hiring statistics')),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StatisticsPage(employerEmail: widget.employerEmail),
                    ),
                  );
                },
                child: Text(
                  'View Stats',
                  style: dashTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementToolsCard(BuildContext context) {
    return Card(
      color: Colors.orange,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Management Tools',
              style: dashTitleStyle,
            ),
            const SizedBox(height: 20),
            const Center(child: Text('Access your management tools')),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManagementToolsPage(
                          employerEmail: widget.employerEmail),
                    ),
                  );
                },
                child: Text(
                  'Go to Tools',
                  style: dashTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _fetchTotalJobPosts({
    int retryCount = 5,
  }) async {
    int attempt = 0;
    while (attempt < retryCount) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('job_posts')
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
// import 'package:codehunt/dashboard/management_tool.dart';
// import 'package:codehunt/dashboard/statistics.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:codehunt/auth/register.dart';
// import 'package:codehunt/employer/managepost.dart';
// import 'package:codehunt/dashboard/company_profile.dart';
// import 'package:codehunt/form_decoration/textstyle.dart';

// class EmployerHomePage extends StatefulWidget {
//   final String employerEmail;

//   const EmployerHomePage({super.key, required this.employerEmail});

//   @override
//   EmployerHomePageState createState() => EmployerHomePageState();
// }

// class EmployerHomePageState extends State<EmployerHomePage> {
//   late Future<int> _totalJobPostsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _totalJobPostsFuture = _fetchTotalJobPosts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Employer Dashboard',
//           style: appBarTextStyle,
//         ),
//         backgroundColor: RegistrationForm.navyColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: FutureBuilder<int>(
//           future: _totalJobPostsFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }
//             final totalJobPosts = snapshot.data ?? 0;
//             return SingleChildScrollView(
//               child: Column(
//                 children: [
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 20.0,
//                       mainAxisSpacing: 10.0,
//                       childAspectRatio: 3 / 4,
//                     ),
//                     itemCount: 4,
//                     itemBuilder: (context, index) {
//                       switch (index) {
//                         case 0:
//                           return _buildJobPostCard(context, totalJobPosts);
//                         case 1:
//                           return _buildCompanyProfileCard(context);
//                         case 2:
//                           return _buildStatisticsCard(context);
//                         case 3:
//                           return _buildManagementToolsCard(context);
//                         default:
//                           return Card(
//                             color: Colors.grey[200],
//                             elevation: 3,
//                             child: Center(
//                               child: Text('Grid Item $index'),
//                             ),
//                           );
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildJobPostCard(BuildContext context, int totalJobPosts) {
//     return Card(
//       color: Colors.yellow,
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Job Postings',
//               style: dashTitleStyle,
//             ),
//             const SizedBox(height: 10),
//             Center(child: Text('Total job postings: $totalJobPosts')),
//             const SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           ManagePostsPage(employerEmail: widget.employerEmail),
//                     ),
//                   );
//                 },
//                 child: Center(
//                   child: Text(
//                     'View Jobs',
//                     style: dashTextStyle,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompanyProfileCard(BuildContext context) {
//     return Card(
//       color: Colors.lightBlueAccent,
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Company Profile',
//               style: dashTitleStyle,
//             ),
//             const SizedBox(height: 25),
//             const Center(child: Text('Edit and view your company profile')),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CompanyProfilePage(
//                           employerEmail: widget.employerEmail),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   'Edit Profile',
//                   style: dashTextStyle,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatisticsCard(BuildContext context) {
//     return Card(
//       color: Colors.green,
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Statistics',
//               style: dashTitleStyle,
//             ),
//             const SizedBox(height: 44),
//             const Center(child: Text('View application and hiring statistics')),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           StatisticsPage(employerEmail: widget.employerEmail),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   'View Stats',
//                   style: dashTextStyle,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildManagementToolsCard(BuildContext context) {
//     return Card(
//       color: Colors.orange,
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Management Tools',
//               style: dashTitleStyle,
//             ),
//             const SizedBox(height: 20),
//             const Center(child: Text('Access your management tools')),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ManagementToolsPage(
//                           employerEmail: widget.employerEmail),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   'Go to Tools',
//                   style: dashTextStyle,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<int> _fetchTotalJobPosts() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('job_posts')
//         .where('employer_email', isEqualTo: widget.employerEmail)
//         .get();
//     return snapshot.docs.length;
//   }
// }

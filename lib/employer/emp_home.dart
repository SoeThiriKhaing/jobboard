import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:codehunt/seeker/seekerdetail.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/auth/register.dart';

class EmployerHomePage extends StatefulWidget {
  final String employerEmail;

  const EmployerHomePage({super.key, required this.employerEmail});

  @override
  EmployerHomePageState createState() => EmployerHomePageState();
}

class EmployerHomePageState extends State<EmployerHomePage> {
  String searchQuery = '';
  late Future<List<DocumentSnapshot>> _seekersFuture;
  final Set<String> savedSeekers = {};

  @override
  void initState() {
    super.initState();
    _seekersFuture = _fetchSeekers();
    _loadSavedSeekers();
  }

  Future<List<DocumentSnapshot>> _fetchSeekers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Jobseeker')
          .where('visibility', isEqualTo: 'Public')
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error fetching seekers: $e");
      return [];
    }
  }

  Future<void> _loadSavedSeekers() async {
    try {
      final savedSeekersSnapshot = await FirebaseFirestore.instance
          .collection('employers')
          .doc(widget.employerEmail)
          .collection('savedSeekers')
          .get();
      setState(() {
        savedSeekers.addAll(savedSeekersSnapshot.docs.map((doc) => doc.id));
      });
    } catch (e) {
      print("Error loading saved seekers: $e");
    }
  }

  Future<void> _toggleSaveSeeker(String seekerId) async {
    final isSaved = savedSeekers.contains(seekerId);
    try {
      if (isSaved) {
        await FirebaseFirestore.instance
            .collection('employers')
            .doc(widget.employerEmail)
            .collection('savedSeekers')
            .doc(seekerId)
            .delete();
        setState(() {
          savedSeekers.remove(seekerId);
        });
      } else {
        await FirebaseFirestore.instance
            .collection('employers')
            .doc(widget.employerEmail)
            .collection('savedSeekers')
            .doc(seekerId)
            .set({});
        setState(() {
          savedSeekers.add(seekerId);
        });
      }
    } catch (e) {
      print("Error saving seeker: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Find The Best Tech',
          style: appBarTextStyle,
        ),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by Seeker name or skill',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _seekersFuture = _fetchSeekers();
                      });
                    },
                    icon: const Icon(Icons.search),
                    color: RegistrationForm.navyColor,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _seekersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final seekers = snapshot.data ?? [];
                final filteredSeekers = seekers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>?;
                  final name =
                      data?['fullName']?.toString().toLowerCase() ?? '';
                  final skill = data?['skills']?.toString().toLowerCase() ?? '';
                  return name.contains(searchQuery) ||
                      skill.contains(searchQuery);
                }).toList();

                return ListView(
                  children: filteredSeekers.map((doc) {
                    final data = doc.data() as Map<String, dynamic>?;
                    final seekerId = doc.id;
                    final isSaved = savedSeekers.contains(seekerId);

                    return Card(
                      color: Colors.white,
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 14.0),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeekerDetailPage(
                                seekerId: seekerId,
                                seekerData: data ?? {},
                              ),
                            ),
                          );
                        },
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          children: [
                            if (data?['profileImageUrl'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  data!['profileImageUrl'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data?['fullName'] ?? 'No data',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.code),
                                      Expanded(
                                        child: Text(
                                          ' ${data?['skills'] ?? 'No data'}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on),
                                      Expanded(
                                        child: Text(
                                          ' ${data?['location'] ?? 'No data'}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isSaved ? Icons.star : Icons.star_border,
                                color: isSaved ? Colors.blue : Colors.grey,
                              ),
                              onPressed: () {
                                _toggleSaveSeeker(seekerId);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ManageUsersPageState createState() => ManageUsersPageState();
}

class ManageUsersPageState extends State<ManageUsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _deleteUser(String userId) async {
    try {
      final currentUser = _auth.currentUser;

      // Ensure the current admin user is not deleted
      if (currentUser != null && currentUser.uid != userId) {
        // Delete the user's Firestore document
        await _firestore.collection('users').doc(userId).delete();

        // Delete associated job posts
        final userPostsSnapshot = await _firestore
            .collection('job_posts')
            .where('userId', isEqualTo: userId)
            .get();

        for (var doc in userPostsSnapshot.docs) {
          await doc.reference.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User and associated data deleted successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete the current admin user'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Manage Users',
            style: appBarTextStyle,
          ),
          backgroundColor: RegistrationForm.navyColor,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Employers'),
              Tab(text: 'Job Seekers'),
            ],
            labelColor: RegistrationForm.navyColor,
            unselectedLabelColor: Colors.black54,
          ),
        ),
        body: const TabBarView(
          children: [
            UserList(role: 'employer'),
            UserList(role: 'jobseeker'),
          ],
        ),
      ),
    );
  }
}

class UserList extends StatelessWidget {
  final String role;

  const UserList({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: role)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userId = user.id;
            final userName = user['name'] ?? 'No name';
            final userEmail = user['email'] ?? 'No email';
            final userRole = user['role'] ?? 'No role';

            return ListTile(
              title: Text(userName),
              subtitle: Text('$userEmail\nRole: $userRole'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                            'Are you sure you want to delete this user?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('Delete'),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await ManageUsersPageState()._deleteUser(userId);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

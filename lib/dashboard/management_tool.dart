import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagementToolsPage extends StatelessWidget {
  final String employerEmail;

  const ManagementToolsPage({super.key, required this.employerEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Tools'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('management_tools')
              .where('employerEmail', isEqualTo: employerEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final tools = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return ListTile(
                  title: Text(tool['toolName']),
                  subtitle: Text(tool['description']),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:codehunt/auth/register.dart';
import 'package:codehunt/employer/editjobpost.dart';
import 'package:codehunt/form_decoration/appbarstyle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePostsPage extends StatelessWidget {
  const ManagePostsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('job_posts').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return Card(
              child: ListTile(
                // title: Text(doc['company'], style: titleTextStyle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (doc['companyLogo'] != null)
                      ClipOval(
                        child: Image.network(
                          doc['companyLogo'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Company Name:${doc['company']}',
                      style: titleTextStyle,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text('JobTitle: ${doc['title']}', style: postTextStyle),
                    const SizedBox(height: 14),
                    Text('SalaryRange: ${doc['salaryRange']}',
                        style: postTextStyle),
                    const SizedBox(height: 14),
                    Text('Job Description: ${doc['description']}',
                        style: postTextStyle),
                    const SizedBox(height: 14),
                    Text('Job Location: ${doc['location']}',
                        style: postTextStyle),
                    const SizedBox(height: 14),
                    Text('Experience Level: ${doc['experienceLevel']}',
                        style: postTextStyle),
                    const SizedBox(height: 14),
                    Text('Required Skills: ${doc['requiredSkills']}',
                        style: postTextStyle),
                    const SizedBox(height: 14),
                    Text('Job Type: ${doc['jobType']}', style: postTextStyle),
                    const SizedBox(height: 14),
                    Text('Posting Date: ${doc['postingDate']}',
                        style: postTextStyle),
                    const SizedBox(height: 14),
                    Text('Ending Date: ${doc['endingDate']}',
                        style: postTextStyle),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: RegistrationForm.navyColor,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditJobPostPage(
                                  jobPostId: doc.id,
                                  jobPostData:
                                      doc.data() as Map<String, dynamic>,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('job_posts')
                                .doc(doc.id)
                                .delete();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

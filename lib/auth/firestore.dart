import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codehunt/employer/emp_data.dart';
import 'package:codehunt/seeker/seeker_data.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Jobseeker> getJobseeker(String jobseekerId) async {
    DocumentSnapshot doc =
        await _db.collection('seekers').doc(jobseekerId).get();
    return Jobseeker.fromDocument(doc);
  }

  Future<Employer> getEmployer(String employerId) async {
    DocumentSnapshot doc =
        await _db.collection('employers').doc(employerId).get();
    return Employer.fromDocument(doc);
  }

  Future<void> updateEmployer(Employer employer) async {
    await _db.collection('employers').doc(employer.id).set(employer.toMap());
  }
}

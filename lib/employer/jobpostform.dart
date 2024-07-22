import 'dart:io';
import 'package:codehunt/auth/login.dart';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:codehunt/utils/validation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class JobPostForm extends StatefulWidget {
  final String employerEmail;

  const JobPostForm({super.key, required this.employerEmail});

  @override
  JobPostFormState createState() => JobPostFormState();
}

class JobPostFormState extends State<JobPostForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _salaryRangeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _postingDateController = TextEditingController();
  final TextEditingController _endingDateController = TextEditingController();
  String? _salaryType;
  String? _jobType;
  File? _companyLogo;

  Future<String?> _postJob() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_formKey.currentState!.validate()) {
      try {
        String? logoUrl;
        if (_companyLogo != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('logos/${DateTime.now()}.png');
          await storageRef.putFile(_companyLogo!);
          logoUrl = await storageRef.getDownloadURL();
        }

        final jobPostRef =
            FirebaseFirestore.instance.collection('job_posts').doc();
        final jobPostId = jobPostRef.id;

        await jobPostRef.set({
          'jobPostId': user?.uid,
          'title': _titleController.text,
          'company': _companyController.text,
          'salaryRange': _salaryRangeController.text,
          'salaryType': _salaryType,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'experienceLevel': _experienceController.text,
          'requiredSkills': _skillsController.text,
          'jobType': _jobType,
          'postingDate': _postingDateController.text,
          'endingDate': _endingDateController.text,
          'companyLogo': logoUrl,
          'postedBy': widget.employerEmail,
        });

        _clear();
        return jobPostId;
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
        return null;
      }
    }
    return null;
  }

  void _clear() {
    _titleController.clear();
    _companyController.clear();
    _salaryRangeController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _experienceController.clear();
    _skillsController.clear();
    _jobTypeController.clear();
    _postingDateController.clear();
    _endingDateController.clear();
    setState(() {
      _salaryType = null;
      _jobType = null;
      _companyLogo = null;
    });
  }

  final InputDecoration _inputDecoration = const InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: RegistrationForm.navyColor),
    ),
  );

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectCompanyLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _companyLogo = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Post a Job",
            style: appBarTextStyle,
          ),
          backgroundColor: RegistrationForm.navyColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text("Please log in to post a job"),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              width: screenWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginForm()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: RegistrationForm.navyColor,
                ),
                child: Text(
                  'Sign in',
                  style: btnTextStyle,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Post a Job', style: appBarTextStyle),
        backgroundColor: RegistrationForm.navyColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration.copyWith(labelText: 'Job Title'),
                validator: validateTextField,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _companyController,
                decoration:
                    _inputDecoration.copyWith(labelText: 'Company Name'),
                validator: validateTextField,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salaryRangeController,
                      decoration:
                          _inputDecoration.copyWith(labelText: 'Salary Range'),
                      validator: validateTextField,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _salaryType,
                      items: ['Annual', 'Monthly', 'Weekly', 'Hourly']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      hint: const Text('Salary Type'),
                      onChanged: (value) {
                        setState(() {
                          _salaryType = value;
                        });
                      },
                      decoration: _inputDecoration,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a salary type';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _jobType,
                      items: ['Full Time', 'Part Time', 'Remote']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      hint: const Text('Job Type'),
                      onChanged: (value) {
                        setState(() {
                          _jobType = value;
                        });
                      },
                      decoration: _inputDecoration,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a job type';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _postingDateController,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Posting Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: validateTextField,
                      readOnly: true,
                      onTap: () => _selectDate(context, _postingDateController),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _endingDateController,
                      decoration: _inputDecoration.copyWith(
                        labelText: 'Ending Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: validateTextField,
                      readOnly: true,
                      onTap: () => _selectDate(context, _endingDateController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration.copyWith(labelText: 'Description'),
                validator: validateTextField,
                maxLines: 5,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration.copyWith(labelText: 'Location'),
                validator: validateTextField,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _experienceController,
                decoration:
                    _inputDecoration.copyWith(labelText: 'Experience Level'),
                validator: validateTextField,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _skillsController,
                decoration: _inputDecoration.copyWith(labelText: 'Skills'),
                validator: validateTextField,
              ),
              const SizedBox(height: 16.0),
              Column(
                children: [
                  Container(
                    width: screenWidth,
                    child: ElevatedButton(
                      onPressed: _selectCompanyLogo,
                      child: const Text(
                        'Select Company Logo',
                        style: TextStyle(color: RegistrationForm.navyColor),
                      ),
                    ),
                  ),
                  if (_companyLogo != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        _companyLogo!,
                        height: 100,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: _postJob,
                  child: Text(
                    'Post Job',
                    style: btnTextStyle,
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: RegistrationForm.navyColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

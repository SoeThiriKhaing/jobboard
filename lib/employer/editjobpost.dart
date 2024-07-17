import 'dart:io';
import 'package:codehunt/auth/register.dart';
import 'package:codehunt/form_decoration/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class EditJobPostPage extends StatefulWidget {
  final String jobPostId;
  final String employerEmail;
  final Map<String, dynamic> jobPostData;

  const EditJobPostPage(
      {super.key, required this.jobPostId, required this.jobPostData,required this.employerEmail});

  @override
  EditJobPostPageState createState() => EditJobPostPageState();
}

class EditJobPostPageState extends State<EditJobPostPage> {
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _salaryRangeController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _experienceController;
  late TextEditingController _skillsController;
  late TextEditingController _jobTypeController;
  late TextEditingController _postingDateController;
  late TextEditingController _endingDateController;
  String? _salaryType;
  File? _companyLogo;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.jobPostData['title']);
    _companyController =
        TextEditingController(text: widget.jobPostData['company']);
    _salaryRangeController =
        TextEditingController(text: widget.jobPostData['salaryRange']);
    _descriptionController =
        TextEditingController(text: widget.jobPostData['description']);
    _locationController =
        TextEditingController(text: widget.jobPostData['location']);
    _experienceController =
        TextEditingController(text: widget.jobPostData['experienceLevel']);
    _skillsController =
        TextEditingController(text: widget.jobPostData['requiredSkills']);
    _jobTypeController =
        TextEditingController(text: widget.jobPostData['jobType']);
    _postingDateController =
        TextEditingController(text: widget.jobPostData['postingDate']);
    _endingDateController =
        TextEditingController(text: widget.jobPostData['endingDate']);
    _salaryType = widget.jobPostData['salaryType'];
  }

  Future<void> _updateJobPost() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? logoUrl = widget.jobPostData['companyLogo'];
        if (_companyLogo != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('logos/${DateTime.now()}.png');
          await storageRef.putFile(_companyLogo!);
          logoUrl = await storageRef.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection('job_posts')
            .doc(widget.jobPostId)
            .update({
          'title': _titleController.text,
          'company': _companyController.text,
          'salaryRange': _salaryRangeController.text,
          'salaryType': _salaryType,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'experienceLevel': _experienceController.text,
          'requiredSkills': _skillsController.text,
          'jobType': _jobTypeController.text,
          'postingDate': _postingDateController.text,
          'endingDate': _endingDateController.text,
          'companyLogo': logoUrl,
        });
        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RegistrationForm.navyColor,
        title: Text(
          "Edit Job Post",
          style: appBarTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Job Title"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: "Company Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _salaryRangeController,
                decoration: const InputDecoration(labelText: "Salary Range"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter salary range';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Job Description"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter job description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Job Location"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter job location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _experienceController,
                decoration:
                    const InputDecoration(labelText: "Experience Level"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter experience level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(labelText: "Required Skills"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter required skills';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _jobTypeController,
                decoration: const InputDecoration(labelText: "Job Type"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter job type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _postingDateController,
                decoration: InputDecoration(
                  labelText: "Posting Date",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          _postingDateController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter posting date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _endingDateController,
                decoration: InputDecoration(
                  labelText: "Ending Date",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          _endingDateController.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ending date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Container(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: _updateJobPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RegistrationForm.navyColor,
                  ),
                  child: Text(
                    'Update Job Post',
                    style: btnTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

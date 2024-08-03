// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, avoid_print, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import 'buyer/buyer_page.dart';

class SetupAccountPage extends StatefulWidget {
  final bool showSuccessNotification;

  SetupAccountPage({this.showSuccessNotification = false});

  @override
  _SetupAccountPageState createState() => _SetupAccountPageState();
}

class _SetupAccountPageState extends State<SetupAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();
  File? _profileImage;
  File? _idPhoto;
  final FocusNode _contactNumberFocusNode = FocusNode();

  @override
  void dispose() {
    _contactNumberFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser; // Refresh user data
    if (user != null) {
      try {
        // Upload profile image to Firebase Storage
        String? profileImageUrl;
        if (_profileImage != null) {
          profileImageUrl = await _uploadFile(_profileImage!, 'profile_images/${user.uid}');
        }

        // Upload ID photo to Firebase Storage
        String? idPhotoUrl;
        if (_idPhoto != null) {
          idPhotoUrl = await _uploadFile(_idPhoto!, 'id_photos/${user.uid}');
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': _firstNameController.text,
          'middleName': _middleNameController.text,
          'lastName': _lastNameController.text,
          'contactNumber': '+63${_contactNumberController.text}',
          'gender': _genderController.text,
          'address': _addressController.text,
          'birthday': _birthdayController.text,
          'email': user.email,
          'profileImage': profileImageUrl ?? '',
          'idPhoto': idPhotoUrl ?? '',
          'isAdmin': false, // Setting isAdmin to false for all new users
          'isEnabled': true, // Setting isEnabled to true for all new users
        });

        // Show success notification after saving user data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registered Successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BuyerPage()),
        );
      } catch (e) {
        print("Error saving user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving user data'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<String> _uploadFile(File file, String path) async {
    UploadTask uploadTask = FirebaseStorage.instance.ref().child(path).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickImage(ImageSource source, bool isProfileImage) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfileImage) {
          _profileImage = File(pickedFile.path);
        } else {
          _idPhoto = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Colors.green, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Setup Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Finish Setting-Up Your Account',
                    style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    cursorColor: Colors.black,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _middleNameController,
                    decoration: InputDecoration(
                      labelText: 'Middle Name',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    cursorColor: Colors.black,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    cursorColor: Colors.black,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Focus(
                    focusNode: _contactNumberFocusNode,
                    child: TextFormField(
                      controller: _contactNumberController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text("🇵🇭 +63", style: TextStyle(fontSize: 16)),
                        ),
                        contentPadding: EdgeInsets.fromLTRB(16, 20, 20, 20),
                      ),
                      cursorColor: Colors.black,
                      maxLength: 10, // Only allow 10 digits input
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.length != 10) {
                          return 'Please enter a valid contact number';
                        }
                        return null;
                      },
                    ),
                    onFocusChange: (hasFocus) {
                      setState(() {
                        // Trigger rebuild to show/hide the prefix based on focus
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    items: <String>['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      _genderController.text = newValue!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    cursorColor: Colors.black,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _birthdayController,
                    decoration: InputDecoration(
                      labelText: 'Birthday',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    cursorColor: Colors.black,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your birthday';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Picture',
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery, true),
                        child: Stack(
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: _profileImage != null
                                  ? Image.file(
                                      _profileImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.add_a_photo, size: 50, color: Colors.black54),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Text(
                                'Upload Image',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID Photo',
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery, false),
                        child: Stack(
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: _idPhoto != null
                                  ? Image.file(
                                      _idPhoto!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.add_a_photo, size: 50, color: Colors.black54),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Text(
                                'Upload ID Photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _saveUserData();
                      }
                    },
                    child: Text(
                      'SUBMIT',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 55, 143, 58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      minimumSize: Size.fromHeight(56),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

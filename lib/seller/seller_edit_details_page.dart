// seller_edit_details_page.dart
// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerEditDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  SellerEditDetailsPage({required this.userData});

  @override
  _SellerEditDetailsPageState createState() => _SellerEditDetailsPageState();
}

class _SellerEditDetailsPageState extends State<SellerEditDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late String firstName;
  late String middleName;
  late String lastName;
  late String address;
  late String birthday;
  late String contactNumber;
  late String gender;
  late String profileImage;

  @override
  void initState() {
    super.initState();
    firstName = widget.userData['firstName'];
    middleName = widget.userData['middleName'];
    lastName = widget.userData['lastName'];
    address = widget.userData['address'];
    birthday = widget.userData['birthday'];
    contactNumber = widget.userData['contactNumber'];
    gender = widget.userData['gender'];
    profileImage = widget.userData['profileImage'];
  }

  Future<void> _updateUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'address': address,
        'birthday': birthday,
        'contactNumber': contactNumber,
        'gender': gender,
        'profileImage': profileImage,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: firstName,
                  decoration: InputDecoration(labelText: 'First Name'),
                  onChanged: (value) => firstName = value,
                ),
                TextFormField(
                  initialValue: middleName,
                  decoration: InputDecoration(labelText: 'Middle Name'),
                  onChanged: (value) => middleName = value,
                ),
                TextFormField(
                  initialValue: lastName,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  onChanged: (value) => lastName = value,
                ),
                TextFormField(
                  initialValue: address,
                  decoration: InputDecoration(labelText: 'Address'),
                  onChanged: (value) => address = value,
                ),
                TextFormField(
                  initialValue: birthday,
                  decoration: InputDecoration(labelText: 'Birthday'),
                  onChanged: (value) => birthday = value,
                ),
                TextFormField(
                  initialValue: contactNumber,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                  onChanged: (value) => contactNumber = value,
                ),
                TextFormField(
                  initialValue: gender,
                  decoration: InputDecoration(labelText: 'Gender'),
                  onChanged: (value) => gender = value,
                ),
                TextFormField(
                  initialValue: profileImage,
                  decoration: InputDecoration(labelText: 'Profile Image URL'),
                  onChanged: (value) => profileImage = value,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _updateUserData();
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

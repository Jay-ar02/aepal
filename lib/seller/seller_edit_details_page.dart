// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

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
  final Map<String, Color> _borderColors = {};

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
      });
    }
  }

  InputDecoration _inputDecoration(String labelText, String field) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.black),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: _borderColors[field] ?? Colors.black),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
    );
  }

  void _onFieldChange(String value, String field) {
    setState(() {
      _borderColors[field] = Colors.green;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
         backgroundColor: Colors.white,
        title: Text('Edit Details'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Update Your Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: firstName,
                    decoration: _inputDecoration('First Name', 'firstName'),
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      firstName = value;
                      _onFieldChange(value, 'firstName');
                    },
                  ),
                  TextFormField(
                    initialValue: middleName,
                    decoration: _inputDecoration('Middle Name', 'middleName'),
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      middleName = value;
                      _onFieldChange(value, 'middleName');
                    },
                  ),
                  TextFormField(
                    initialValue: lastName,
                    decoration: _inputDecoration('Last Name', 'lastName'),
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      lastName = value;
                      _onFieldChange(value, 'lastName');
                    },
                  ),
                  TextFormField(
                    initialValue: address,
                    decoration: _inputDecoration('Address', 'address'),
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      address = value;
                      _onFieldChange(value, 'address');
                    },
                  ),
                  TextFormField(
                    initialValue: birthday,
                    decoration: _inputDecoration('Birthday', 'birthday'),
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      birthday = value;
                      _onFieldChange(value, 'birthday');
                    },
                  ),
                  TextFormField(
                    initialValue: contactNumber,
                    decoration: _inputDecoration('Contact Number', 'contactNumber'),
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      contactNumber = value;
                      _onFieldChange(value, 'contactNumber');
                    },
                  ),
                  TextFormField(
                    initialValue: gender,
                    decoration: _inputDecoration('Gender', 'gender'),
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      gender = value;
                      _onFieldChange(value, 'gender');
                    },
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateUserData();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
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

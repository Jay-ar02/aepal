// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'add_address_page.dart';
import 'edit_address_page.dart';
import 'seller_page.dart';
import 'package:intl/intl.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _availableKilosController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  int? _timeDurationHours;
  bool _isTimerEnabled = true;
  String _productStatus = 'BIDDING SOON';
  List<File> _images = []; 
  final ImagePicker _picker = ImagePicker();
  String _addressText = "Street, Barangay, Municipality";

  DateTime? _selectedScheduleDate; // New field for scheduling

  Future<void> _pickImage() async {
    final pickedFiles = await _picker.pickMultiImage();

    setState(() {
      if (pickedFiles != null) {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      }
    });
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> downloadUrls = [];
    try {
      for (var image in images) {
        final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().toIso8601String()}_${image.path.split('/').last}');
        final uploadTask = storageRef.putFile(image);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
    } catch (e) {
      print('Error uploading images: $e');
    }
    return downloadUrls;
  }

  Future<void> _addProduct(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final productName = _productNameController.text.isNotEmpty ? _productNameController.text : 'Unknown Product';
        final availableKilos = _availableKilosController.text.isNotEmpty ? int.parse(_availableKilosController.text) : 0;
        final minAmount = _minAmountController.text.isNotEmpty ? double.parse(_minAmountController.text) : 0.0;
        final address = _addressText.isNotEmpty ? _addressText : 'Unknown Address';

        List<String> imageUrls = [];
        if (_images.isNotEmpty) {
          imageUrls = await _uploadImages(_images);
        }

        DateTime? endTime;
        if (_isTimerEnabled && _timeDurationHours != null) {
          endTime = DateTime.now().add(Duration(hours: _timeDurationHours!));
        } else {
          endTime = null;
        }

        await FirebaseFirestore.instance.collection('products').add({
          'userId': user.uid,
          'productName': productName,
          'address': address,
          'availableKilos': availableKilos,
          'minAmount': minAmount,
          'timeDuration': endTime?.toIso8601String(),
          'status': _productStatus,
          'imageUrls': imageUrls,
          'scheduledPostDate': _selectedScheduleDate?.toIso8601String(), // Schedule field
        });

        Navigator.pushReplacementNamed(context, '/sellerPage');
      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product. Please try again.')),
        );
      }
    }
  }

  Future<void> _selectScheduleDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        setState(() {
          _selectedScheduleDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  void _navigateToAddAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAddressPage()),
    );
  }

  void _navigateToEditAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAddressPage()),
    );
  }

  Future<void> _refreshData() async {
    await _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final document = await FirebaseFirestore.instance.collection('addresses').doc(user.uid).get();
        if (document.exists) {
          final data = document.data();
          if (data != null) {
            setState(() {
              _addressText = "${data['street']}, ${data['barangay']}, ${data['municipality']}";
            });
          }
        }
      } catch (e) {
        print('Error fetching address: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch address. Please try again.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Add Product'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.green,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            GestureDetector(
              onTap: _navigateToAddAddress,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Add Address',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward, color: Colors.black),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Address:',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _addressText,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToEditAddress,
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Divider(
              color: Colors.black,
              thickness: 1,
              height: 40,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _images.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey[700],
                        ),
                      )
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              _images.first,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (_images.length > 1)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Text(
                                'More...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _productNameController,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: 'Product Name',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _availableKilosController,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: 'Available Kilos',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _minAmountController,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: 'Minimum Amount to Bid',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<bool>(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Enable Timer',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    value: _isTimerEnabled,
                    items: [
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Enable'),
                      ),
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('Disable'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _isTimerEnabled = value!;
                        if (!_isTimerEnabled) {
                          _timeDurationHours = null;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Time Duration (hours)',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    items: List.generate(12, (index) => index + 1)
                        .map((duration) => DropdownMenuItem<int>(
                              value: duration,
                              child: Text('$duration hours'),
                            ))
                        .toList(),
                    onChanged: _isTimerEnabled
                        ? (value) {
                            setState(() {
                              _timeDurationHours = value;
                            });
                          }
                        : null,
                    value: _timeDurationHours,
                    isExpanded: true,
                    hint: Text(
                      _isTimerEnabled ? 'Select Duration' : 'Disabled',
                      style: TextStyle(color: _isTimerEnabled ? Colors.black : Colors.grey),
                    ),
                    disabledHint: Text(
                      'Disabled',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectScheduleDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Schedule Post Date',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _selectedScheduleDate != null
                        ? DateFormat('yyyy-MM-dd – kk:mm').format(_selectedScheduleDate!)
                        : 'Select Date & Time',
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Product Status',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              value: _productStatus,
              items: ['BIDDING SOON', 'OPEN FOR BIDDING']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _productStatus = value!;
                });
              },
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _addProduct(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 55, 143, 58)),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(vertical: 15),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddProductPage(),
    routes: {
      '/sellerPage': (context) => SellerPage(),
      '/addAddressPage': (context) => AddAddressPage(),
      '/editAddressPage': (context) => EditAddressPage(),
    },
  ));
}

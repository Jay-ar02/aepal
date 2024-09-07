// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProductPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  EditProductPage({required this.productId, required this.productData});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _productNameController;
  late TextEditingController _addressController;
  late TextEditingController _availableKilosController;
  late TextEditingController _minAmountController;
  DateTime? _timeDuration;
  bool _isTimerEnabled = true;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(text: widget.productData['productName'] ?? '');
    _addressController = TextEditingController(text: widget.productData['address'] ?? '');
    _availableKilosController = TextEditingController(text: widget.productData['availableKilos']?.toString() ?? '0');
    _minAmountController = TextEditingController(text: widget.productData['minAmount']?.toString() ?? '0');

    if (widget.productData['timeDuration'] != null) {
      _timeDuration = DateTime.parse(widget.productData['timeDuration']);
      _isTimerEnabled = true;
    } else {
      _isTimerEnabled = false;
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _addressController.dispose();
    _availableKilosController.dispose();
    _minAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateProduct() async {
    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      } else {
        imageUrl = widget.productData['imageUrl'];
      }

      String? timeDurationString;
      if (_isTimerEnabled && _timeDuration != null) {
        timeDurationString = _timeDuration!.toIso8601String();
      }

      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'productName': _productNameController.text,
        'address': _addressController.text,
        'availableKilos': int.parse(_availableKilosController.text),
        'minAmount': double.parse(_minAmountController.text),
        'timeDuration': timeDurationString,
        'imageUrl': imageUrl ?? '',
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error updating product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product. Please try again.')),
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _timeDuration ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 55, 143, 58),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 55, 143, 58),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_timeDuration ?? DateTime.now()),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Color.fromARGB(255, 55, 143, 58),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 55, 143, 58),
                ),
              ),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          _timeDuration = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
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
        title: Text('Edit Product'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SizedBox(height: 16),
          Divider(
            color: Colors.black,
            thickness: 1,
            height: 40,
          ),
          SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 400,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                        : widget.productData['imageUrl'] != null
                            ? DecorationImage(
                                image: NetworkImage(widget.productData['imageUrl']),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: _image == null && widget.productData['imageUrl'] == null
                      ? Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey[700],
                          ),
                        )
                      : null,
                ),
              ),
              if (_image == null && widget.productData['imageUrl'] == null)
                Positioned(
                  bottom: 8,
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
                        _timeDuration = null;
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
                            _timeDuration = DateTime.now().add(Duration(hours: value!));
                          });
                        }
                      : null,
                  value: _timeDuration?.difference(DateTime.now()).inHours,
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
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateProduct,
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
                'UPDATE PRODUCT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
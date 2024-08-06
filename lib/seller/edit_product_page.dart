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
  late TextEditingController _timeDurationController;
  late TextEditingController _imageUrlController;
  String? _timeDuration;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _productStatus = 'BIDDING SOON'; // Add product status field

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(text: widget.productData['productName'] ?? '');
    _addressController = TextEditingController(text: widget.productData['address'] ?? '');
    _availableKilosController = TextEditingController(text: widget.productData['availableKilos']?.toString() ?? '0');
    _minAmountController = TextEditingController(text: widget.productData['minAmount']?.toString() ?? '0');
    _timeDurationController = TextEditingController(text: widget.productData['timeDuration'] ?? '');
    _imageUrlController = TextEditingController(text: widget.productData['imageUrl'] ?? '');
    _timeDuration = widget.productData['timeDuration'];
    _productStatus = widget.productData['status'] ?? 'BIDDING SOON'; // Initialize product status
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _addressController.dispose();
    _availableKilosController.dispose();
    _minAmountController.dispose();
    _timeDurationController.dispose();
    _imageUrlController.dispose();
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

      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'productName': _productNameController.text,
        'address': _addressController.text,
        'availableKilos': int.parse(_availableKilosController.text),
        'minAmount': double.parse(_minAmountController.text),
        'timeDuration': _timeDuration ?? '',
        'status': _productStatus, // Update product status
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
          // Address Box
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
                        _addressController.text,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {}, // Navigation for editing address could be added here
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.green, // Set the color to green
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
                        : (_imageUrlController.text.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_imageUrlController.text),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: _image == null && _imageUrlController.text.isEmpty
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
              if (_image == null && _imageUrlController.text.isEmpty)
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
          DropdownButtonFormField<String>(
            value: _timeDuration,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Time Duration',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            items: List.generate(
              12,
              (index) => (index + 1).toString() + (index + 1 == 1 ? 'hr' : 'hrs'),
            ).map((duration) => DropdownMenuItem(
              value: duration,
              child: Text(duration),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _timeDuration = value;
              });
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _productStatus,
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
              onPressed: _updateProduct,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 55, 143, 58)),
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(vertical: 15),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
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

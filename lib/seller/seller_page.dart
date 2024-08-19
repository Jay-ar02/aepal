// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_to_list_in_spreads

import 'dart:async';
import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'seller_notification_page.dart';
import 'seller_profile_page.dart';
import 'view_bidders_page.dart';
import 'edit_product_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SellerPage(),
      routes: {
        '/sellerNotifications': (context) => SellerNotificationPage(),
        '/sellerProfile': (context) => SellerProfilePage(),
      },
    );
  }
}

class SellerPage extends StatefulWidget {
  @override
  _SellerPageState createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  int _selectedIndex = 0;
  String? _firstName;
  String? _profileImageUrl;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchNotifications();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _firstName = userDoc['firstName'] ?? 'Profile';
          _profileImageUrl = userDoc['profileImage'] ?? 'https://via.placeholder.com/150';
        });
      }
    }
  }

  Future<void> _fetchNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final notifications = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      setState(() {
        _unreadNotifications = notifications.docs.length;
      });
    }
  }

  Future<Map<String, String>> _fetchSellerDetails(String sellerId) async {
    if (sellerId.isEmpty) return {'name': 'Unknown', 'profileImageUrl': ''};

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
      if (userDoc.exists) {
        String firstName = userDoc['firstName'] ?? 'Unknown';
        String lastName = userDoc['lastName'] ?? '';
        String profileImageUrl = userDoc['profileImage'] ?? 'https://via.placeholder.com/150';
        return {'name': '$firstName $lastName', 'profileImageUrl': profileImageUrl};
      }
    } catch (e) {
      print("Error fetching seller data: $e");
    }
    return {'name': 'Unknown', 'profileImageUrl': ''};
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/sellerPage');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/sellerNotifications');
          break;
        case 2:
          if (!ModalRoute.of(context)!.settings.name!.contains('/sellerProfile')) {
            Navigator.pushNamed(context, '/sellerProfile');
          }
          break;
        default:
          break;
      }
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
    } catch (e) {
      print("Error deleting product: $e");
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Delete Product',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            'Are you sure you want to delete this product?',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                _deleteProduct(productId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showProductOptionsDialog(BuildContext context, String productId, Map<String, dynamic> productData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Product Options',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            'What would you like to do with this product?',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Edit',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductPage(productId: productId, productData: productData),
                  ),
                );
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(context, productId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshProducts() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Bagsakan'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        color: Colors.green,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Mode Container
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Seller Mode',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'MY PRODUCTS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<String>(
                future: Future.value(''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.green));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('No products available.'));
                  }

                  return FutureBuilder<String>(
                    future: Future.value(FirebaseAuth.instance.currentUser?.uid ?? ''),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: Colors.green));
                      }
                      if (!userSnapshot.hasData) {
                        return Center(child: Text('No products available.'));
                      }
                      final userId = userSnapshot.data!;

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .where('userId', isEqualTo: userId)
                            .snapshots(),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(color: Colors.green));
                          }
                          if (!productSnapshot.hasData) {
                            return Center(child: Text('No products available.'));
                          }
                          var products = productSnapshot.data!.docs;
                          return GridView.builder(
                            padding: EdgeInsets.all(10),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.61,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              var product = products[index];
                              var productId = product.id;
                              var userId = product['userId'] ?? '';
                              var productData = product.data() as Map<String, dynamic>;
                              DateTime? scheduledDate = product['scheduledPostDate'] != null
                                  ? DateTime.parse(product['scheduledPostDate'])
                                  : null;
                              bool isScheduled = scheduledDate != null && DateTime.now().isBefore(scheduledDate);

                              return FutureBuilder<Map<String, String>>(
                                future: _fetchSellerDetails(userId),
                                builder: (context, sellerSnapshot) {
                                  if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator(color: Colors.green));
                                  }
                                  var sellerDetails = sellerSnapshot.data ?? {'name': 'Unknown', 'profileImageUrl': ''};
                                  return ProductCard(
                                    productId: productId,
                                    sellerName: sellerDetails['name']!,
                                    profileImageUrl: sellerDetails['profileImageUrl']!,
                                    imageUrls: List<String>.from(product['imageUrls']), 
                                    title: product['productName'],
                                    location: product['address'],
                                    availableKgs: product['availableKilos'],
                                    minAmount: product['minAmount'],
                                    endTime: product['timeDuration'] != null
                                        ? DateTime.parse(product['timeDuration'])
                                        : null,
                                    productStatus: product['status'],
                                    scheduledDate: scheduledDate, 
                                    onPressed: () {
                                      if (!isScheduled) {
                                        Navigator.pushNamed(
                                          context,
                                          '/viewBidders',
                                          arguments: {'productId': productId},
                                        );
                                      }
                                    },
                                    onLongPress: () {
                                      _showProductOptionsDialog(context, productId, productData);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: _unreadNotifications > 0,
              badgeContent: Text(
                _unreadNotifications.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.notifications),
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: _profileImageUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(_profileImageUrl!),
                    radius: 12,
                  )
                : Icon(Icons.person),
            label: _firstName ?? 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 55, 143, 58),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productId;
  final String sellerName;
  final String profileImageUrl;
  final List<String> imageUrls; 
  final String title;
  final String location;
  final int availableKgs;
  final double minAmount;
  final DateTime? endTime;
  final String productStatus;
  final DateTime? scheduledDate; 
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  ProductCard({
    required this.productId,
    required this.sellerName,
    required this.profileImageUrl,
    required this.imageUrls,
    required this.title,
    required this.location,
    required this.availableKgs,
    required this.minAmount,
    this.endTime,
    required this.productStatus,
    this.scheduledDate,
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle smallFontSize = TextStyle(fontSize: 12);
    final now = DateTime.now();
    final duration = endTime != null ? endTime!.difference(now) : Duration.zero;

    return GestureDetector(
      onLongPress: onLongPress,
      child: SizedBox(
        height: 270,
        child: Card(
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                      radius: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sellerName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue, size: 16),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(7), bottom: Radius.circular(7)),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrls.first,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (imageUrls.length > 1)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => ImageGalleryModal(imageUrls: imageUrls),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            color: Colors.black54,
                            child: Text(
                              'More...',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'AVAILABLE KLS.: $availableKgs',
                        style: smallFontSize,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Time Remaining: ',
                            style: smallFontSize.copyWith(color: Colors.black),
                          ),
                          endTime != null
                              ? StreamBuilder<int>(
                                  stream: _countdownStream(duration),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData || snapshot.data! <= 0) {
                                      return Text(
                                        '00:00:00',
                                        style: smallFontSize.copyWith(color: Colors.red),
                                      );
                                    } else {
                                      final remainingDuration = Duration(seconds: snapshot.data!);
                                      return Text(
                                        _formatDuration(remainingDuration),
                                        style: smallFontSize.copyWith(color: Colors.red),
                                      );
                                    }
                                  },
                                )
                              : Text(
                                  'Disabled',
                                  style: smallFontSize.copyWith(color: Colors.grey),
                                ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Minimum Amount: ₱${minAmount.toStringAsFixed(2)}',
                        style: smallFontSize.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: (scheduledDate != null && DateTime.now().isBefore(scheduledDate!)) ? 40 : 30, // Adjusted height
                        child: ElevatedButton(
                          onPressed: scheduledDate == null || DateTime.now().isAfter(scheduledDate!)
                              ? onPressed
                              : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                scheduledDate == null || DateTime.now().isAfter(scheduledDate!)
                                    ? 'VIEW BIDDERS'
                                    : 'SCHEDULED',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              if (scheduledDate != null && DateTime.now().isBefore(scheduledDate!))
                                Text(
                                  DateFormat('MMM d, hh:mm a').format(scheduledDate!),
                                  style: TextStyle(color: Colors.red[300], fontSize: 9),
                                ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheduledDate == null || DateTime.now().isAfter(scheduledDate!)
                                ? Colors.green
                                : Colors.grey,
                            padding: EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<int> _countdownStream(Duration duration) async* {
    int seconds = duration.inSeconds;
    while (seconds >= 0) {
      await Future.delayed(Duration(seconds: 1));
      yield seconds--;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

class ImageGalleryModal extends StatelessWidget {
  final List<String> imageUrls;

  ImageGalleryModal({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6, // set a max height for the dialog
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: imageUrls.map((url) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white,),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
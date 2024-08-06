// ignore_for_file: unused_import, use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api, avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables, sort_child_properties_last, prefer_interpolation_to_compose_strings, unused_local_variable, sized_box_for_whitespace

import 'dart:async';

import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'seller_notification_page.dart';
import 'seller_profile_page.dart'; 
import 'view_bidders_page.dart'; 
import 'edit_product_page.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final firstName = doc['firstName'] ?? 'Unknown';
        final lastName = doc['lastName'] ?? 'Seller';
        return '$firstName $lastName';
      } catch (e) {
        print("Error fetching user data: $e");
        return 'Unknown Seller';
      }
    }
    return 'Unknown Seller';
  }

  Future<String> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return '';
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
            SearchBar(),
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
                future: _getUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.green));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('No products available.'));
                  }
                  final sellerName = snapshot.data!;

                  return FutureBuilder<String>(
                    future: _getUserId(),
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
                              childAspectRatio: 0.65,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              var product = products[index];
                              var productId = product.id;
                              var userId = product['userId'] ?? '';
                              var productData = product.data() as Map<String, dynamic>;

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
                                    imageUrl: product['imageUrl'] ?? 'https://via.placeholder.com/150',
                                    title: product['productName'],
                                    location: product['address'],
                                    availableKgs: product['availableKilos'],
                                    timeDuration: product['timeDuration'],
                                    productStatus: product['status'], // Add product status to the ProductCard
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/viewBidders',
                                        arguments: {'productId': productId},
                                      );
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
            icon: const Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 55, 143, 58),
        onTap: _onItemTapped,
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final StreamController<String> _searchStreamController = StreamController<String>();

  @override
  void dispose() {
    _controller.dispose();
    _searchStreamController.close();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchStreamController.add(query);
  }

  Stream<List<Map<String, dynamic>>> _search(String query) async* {
    if (query.isEmpty) {
      yield [];
    } else {
      final userResults = await FirebaseFirestore.instance
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final productResults = await FirebaseFirestore.instance
          .collection('products')
          .where('productName', isGreaterThanOrEqualTo: query)
          .where('productName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final combinedResults = [
        ...userResults.docs.map((doc) => {
              'type': 'user',
              'firstName': doc['firstName'],
              'lastName': doc['lastName'],
              'uid': doc.id,
            }),
        ...productResults.docs.map((doc) => {
              'type': 'product',
              'productName': doc['productName'],
              'productId': doc.id,
            }),
      ];

      yield combinedResults;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search here',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ),
        StreamBuilder<String>(
          stream: _searchStreamController.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container();
            }

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _search(snapshot.data!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.green));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final results = snapshot.data ?? [];
                if (results.isEmpty) {
                  return Center(child: Text('No results found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    if (result['type'] == 'user') {
                      return ListTile(
                        title: Text('${result['firstName']} ${result['lastName']}'),
                        subtitle: Text('User ID: ${result['uid']}'),
                        onTap: () {},
                      );
                    } else {
                      return ListTile(
                        title: Text(result['productName']),
                        subtitle: Text('Product ID: ${result['productId']}'),
                        onTap: () {},
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productId;
  final String sellerName;
  final String profileImageUrl;
  final String imageUrl;
  final String title;
  final String location;
  final int availableKgs;
  final String timeDuration;
  final String productStatus; // Add product status to the ProductCard
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  ProductCard({
    required this.productId,
    required this.sellerName,
    required this.profileImageUrl,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.availableKgs,
    required this.timeDuration,
    required this.productStatus, // Add product status to the ProductCard
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle smallFontSize = TextStyle(fontSize: 12);

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
                child: Image.network(
                  imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                            'Time Duration: ',
                            style: smallFontSize.copyWith(color: Colors.black),
                          ),
                          Text(
                            timeDuration,
                            style: smallFontSize.copyWith(color: Colors.red),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: productStatus == 'BIDDING SOON' ? null : onPressed,
                          child: Text(
                            productStatus == 'BIDDING SOON' ? 'BIDDING SOON' : 'VIEW BIDDERS',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: productStatus == 'BIDDING SOON' ? Colors.grey : Colors.green,
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
}


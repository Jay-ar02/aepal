import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'buyer_profile_page.dart';

class BuyerPage extends StatefulWidget {
  final bool showSuccessNotification;

  const BuyerPage({this.showSuccessNotification = false});

  @override
  _BuyerPageState createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  int _selectedIndex = 0;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchNotifications(); // Fetch notifications on init
    if (widget.showSuccessNotification) {
      Future.delayed(Duration.zero, () {
        Fluttertoast.showToast(
          msg: "Login Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });
    }
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {});
        }
      } catch (e) {
        print("Error fetching user data: $e");
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

  Future<String> _fetchSellerName(String sellerId) async {
    if (sellerId.isEmpty) return 'Unknown';

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
      if (userDoc.exists) {
        String firstName = userDoc['firstName'] ?? 'Unknown';
        String lastName = userDoc['lastName'] ?? '';
        return '$firstName $lastName';
      }
    } catch (e) {
      print("Error fetching seller data: $e");
    }
    return 'Unknown';
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      // Navigating to notifications, mark them as read
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.update({'read': true});
        }
      });

      setState(() {
        _unreadNotifications = 0; // Reset unread notifications count
      });
    }

    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/buyerNotifications');
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BuyerProfilePage()),
        );
        break;
      default:
        break;
    }
  }

  Future<void> _refreshProducts() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bagsakan'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
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
                'BROWSE ALL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.green));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No products available.'));
                  }
                  var products = snapshot.data!.docs;
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
                      var productId = product.id; // Adjust according to your data structure
                      var userId = product['userId'] ?? ''; // Ensure userId is fetched

                      return FutureBuilder<String>(
                        future: _fetchSellerName(userId),
                        builder: (context, sellerSnapshot) {
                          if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(color: Colors.green));
                          }
                          return ProductCard(
                            sellerName: sellerSnapshot.data ?? 'Unknown',
                            imageUrl: product['imageUrl'] ?? 'https://via.placeholder.com/150',
                            title: product['productName'],
                            location: product['address'],
                            availableKgs: product['availableKilos'],
                            minAmount: product['minAmount'],
                            timeDuration: product['timeDuration'],
                            productId: productId,
                            ownerId: userId,
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: _unreadNotifications > 0,
              badgeContent: Text(
                _unreadNotifications.toString(),
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.notifications),
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 55, 143, 58),
        unselectedItemColor: Colors.grey,
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
              return Container(); // Hide suggestions when search query is empty
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
                  shrinkWrap: true, // Limit the height of ListView
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    if (result['type'] == 'user') {
                      return ListTile(
                        title: Text('${result['firstName']} ${result['lastName']}'),
                        subtitle: Text('User ID: ${result['uid']}'),
                        onTap: () {
                          // Handle user tap
                        },
                      );
                    } else {
                      return ListTile(
                        title: Text(result['productName']),
                        subtitle: Text('Product ID: ${result['productId']}'),
                        onTap: () {
                          // Handle product tap
                        },
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
  final String sellerName;
  final String imageUrl;
  final String title;
  final String location;
  final int availableKgs;
  final double minAmount;
  final String timeDuration;
  final String productId;
  final String ownerId; // Add ownerId here

  const ProductCard({
    required this.sellerName,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.availableKgs,
    required this.minAmount,
    required this.timeDuration,
    required this.productId,
    required this.ownerId, // Add ownerId here
  });

  Future<bool> _hasUserPlacedBid(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .collection('bids')
            .where('userId', isEqualTo: user.uid)
            .get();
        return querySnapshot.docs.isNotEmpty;
      } catch (e) {
        print("Error checking user bid: $e");
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle smallFontSize = TextStyle(fontSize: 12);

    return Card(
      color: Colors.grey[100], // Set the card color to light gray
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              sellerName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
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
                  ),
                  Text(location, style: smallFontSize.copyWith(fontStyle: FontStyle.italic)),
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
                  FutureBuilder<bool>(
                    future: _hasUserPlacedBid(productId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: Colors.green));
                      }
                      if (snapshot.hasError || !snapshot.data!) {
                        // Show offer bid button if there's an error or user has not bid
                        return Container(
                          width: double.infinity,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              _showOfferBidModal(context, productId, minAmount);
                            },
                            child: Text(
                              'OFFER BID',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Show a disabled button or alternative text indicating bid placed
                        return Container(
                          width: double.infinity,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: null,
                            child: Text(
                              'BID PLACED',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showOfferBidModal(BuildContext context, String productId, double minAmount) {
  TextEditingController _bidAmountController = TextEditingController();
  bool _isValidBid = true;
  String _errorMessage = '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'OFFER HIGHEST BID',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Minimum is ',
                            style: TextStyle(fontSize: 16),
                          ),
                          TextSpan(
                            text: '₱${minAmount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Theme(
                      data: ThemeData(
                        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
                      ),
                      child: TextField(
                        controller: _bidAmountController,
                        decoration: InputDecoration(
                          hintText: '₱0.00',
                          errorText: _isValidBid ? null : _errorMessage,
                          errorStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          filled: true,
                          fillColor: Colors.grey[300],
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            if (double.parse(value.trim() == '' ? '0' : value.trim()) < minAmount) {
                              _isValidBid = false;
                              _errorMessage = 'Bid must be higher than ₱${minAmount.toStringAsFixed(2)}';
                            } else {
                              _isValidBid = true;
                              _errorMessage = '';
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isValidBid
                            ? () async {
                                final bidAmount = double.parse(_bidAmountController.text);

                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  // Retrieve user data from Firestore
                                  final userData = await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .get();

                                  // Extract user details
                                  final firstName = userData['firstName'];
                                  final lastName = userData['lastName'];
                                  final contactNumber = userData['contactNumber'];

                                  // Store bid information in Firestore
                                  await FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(productId)
                                      .collection('bids')
                                      .add({
                                    'userId': user.uid,
                                    'firstName': firstName,
                                    'lastName': lastName,
                                    'contactNumber': contactNumber,
                                    'amount': bidAmount,
                                  });

                                  // Add a notification for the bid
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .collection('notifications')
                                      .add({
                                    'productId': productId,
                                    'productName': 'Product Name', // Replace with actual product name
                                    'message': 'Bidding successful, We will notify you if you are the winner.',
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'read': false,
                                  });

                                  // Show a notification or toast here if needed
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Bid placed successfully!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }

                                Navigator.pop(context); // Close the modal sheet
                              }
                            : null,
                        child: Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Note: We’ll let you know if you’re the winning bidder.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

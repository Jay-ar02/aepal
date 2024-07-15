import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'seller_notification_page.dart';
import 'seller_profile_page.dart'; // Import the profile page
import 'view_bidders_page.dart'; // Import the view bidders page
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
        return '$firstName $lastName'; // Combine firstName and lastName
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
          // Check if the current route is already SellerProfilePage, if not, navigate to it
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
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
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

  Future<void> _refreshProducts() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2));
    setState(() {}); // Refresh the state to reload products
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bagsakan'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Handle filter action
            },
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
                            .where('userId', isEqualTo: userId) // Filter by userId
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
                              return ProductCard(
                                productId: product.id, // Pass the product ID
                                sellerName: sellerName, // Use fetched seller name
                                imageUrl: product['imageUrl'] ?? 'https://via.placeholder.com/150',
                                title: product['productName'],
                                location: product['address'],
                                availableKgs: product['availableKilos'],
                                timeDuration: product['timeDuration'],
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/viewBidders',
                                    arguments: {'productId': product.id}, // Pass productId as arguments
                                  );
                                },
                                onLongPress: () {
                                  _showDeleteConfirmationDialog(context, product.id);
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

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
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
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              'SEARCH',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productId; // Add productId
  final String sellerName;
  final String imageUrl;
  final String title;
  final String location;
  final int availableKgs;
  final String timeDuration; // Changed from Duration to String
  final VoidCallback onPressed;
  final VoidCallback onLongPress; // Add onLongPress

  ProductCard({
    required this.productId,
    required this.sellerName,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.availableKgs,
    required this.timeDuration,
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle smallFontSize = TextStyle(fontSize: 12);

    return GestureDetector(
      onLongPress: onLongPress, // Handle long press
      child: Card(
        color: Colors.grey[100], // Set the card color to light gray
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sellerName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
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
                    Text('AVAILABLE KLS.: $availableKgs', style: smallFontSize),
                    Row(
                      children: [
                        Text(
                          'Time Duration: ',
                          style: smallFontSize,
                        ),
                        Text(
                          timeDuration,
                          style: smallFontSize.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: onPressed,
                      child: Text(
                        'VIEW BIDDERS',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                        minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 30)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
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
    );
  }
}

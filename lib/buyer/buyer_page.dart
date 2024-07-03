import 'package:aepal/buyer/buyer_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BuyerPage extends StatefulWidget {
  final bool showSuccessNotification;

  BuyerPage({this.showSuccessNotification = false});

  @override
  _BuyerPageState createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  int _selectedIndex = 0;
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
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
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _currentUserName = userDoc['name'] ?? 'Unknown';
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  void _onItemTapped(int index) {
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

  Future<String> _fetchSellerName(String sellerId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
      if (userDoc.exists) {
        return userDoc['name'] ?? 'Unknown';
      }
    } catch (e) {
      print("Error fetching seller data: $e");
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
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
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
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
                    return FutureBuilder<String>(
                      future: _fetchSellerName(product['userId']),
                      builder: (context, sellerSnapshot) {
                        if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ProductCard(
                          sellerName: sellerSnapshot.data ?? 'Unknown',
                          imageUrl: product['imageUrl'] ?? 'https://via.placeholder.com/150', // Use placeholder if imageUrl is null
                          title: product['productName'],
                          location: product['address'],
                          availableKgs: product['availableKilos'],
                          minAmount: product['minAmount'],
                          timeDuration: product['timeDuration'],
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
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
  final String sellerName;
  final String imageUrl;
  final String title;
  final String location;
  final int availableKgs;
  final double minAmount;
  final String timeDuration;

  ProductCard({
    required this.sellerName,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.availableKgs,
    required this.minAmount,
    required this.timeDuration,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle smallFontSize = TextStyle(fontSize: 12);

    return Card(
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
                  Container(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        _showOfferBidModal(context);
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfferBidModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
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
                    'OFFER BID',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter your amount here',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('CANCEL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Add your offer bid logic here
                          Navigator.pop(context);
                        },
                        child: Text('SUBMIT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:aepal/seller/seller_edit_details_page.dart';
import 'package:badges/badges.dart' as badge;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'buyer_notification_page.dart';
import 'buyer_page.dart';
import '../seller/seller_page.dart';

class BuyerProfilePage extends StatefulWidget {
  @override
  _BuyerProfilePageState createState() => _BuyerProfilePageState();
}

class _BuyerProfilePageState extends State<BuyerProfilePage> {
  int _selectedIndex = 2; // Set default index to Profile
  int _selectedButtonIndex = 0; // For the selectable buttons (Posts and Images)
  int _unreadNotifications = 0;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userPosts = [];
  List<String> _userImages = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchNotifications(); 
    _fetchUserPosts();
    _fetchUserImages();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
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

  Future<void> _fetchUserPosts() async {
    final user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot postsSnapshot = await _firestore
          .collection('products')
          .where('userId', isEqualTo: user.uid)
          .get();
      setState(() {
        _userPosts = postsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _fetchUserImages() async {
    final user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot imagesSnapshot = await _firestore
          .collection('products')
          .where('userId', isEqualTo: user.uid)
          .get();
      setState(() {
        _userImages = imagesSnapshot.docs
            .map((doc) => doc['imageUrl'] as String)
            .toList();
      });
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _fetchUserData(),
      _fetchNotifications(),
      _fetchUserPosts(),
      _fetchUserImages(),
    ]);
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BuyerPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BuyerNotificationPage()),
        );
        break;
      case 2:
        // Current page, do nothing
        break;
      default:
        break;
    }
  }

  void _onButtonTapped(int index) {
    setState(() {
      _selectedButtonIndex = index;
    });
  }

  void _updateProfileImage() async {
    // Implement the logic to update profile image and upload it to Firestore
    // Update _userData['profileImage'] and call setState to refresh the UI
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
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        actions: [
  IconButton(
    icon: Icon(Icons.logout),
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white, // Set the background color of the modal
            title: Text("Logout"),
            content: Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red, // Set the color for 'No' button
                ),
              ),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
                child: Text("Yes"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green, // Set the color for 'Yes' button
                ),
              ),
            ],
          );
        },
      );
    },
  ),
],

        title: Text('Profile'),
        centerTitle: true,
      ),
      body: _userData == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.green,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 220, // Increased height to accommodate button placement
                          color: Colors.green,
                        ),
                        Positioned(
                          top: 16, // Adjusted top position
                          left: -23, // Adjusted left position
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(18.0),
                                    bottomRight: Radius.circular(18.0),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SellerPage()),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shopping_cart, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text(
                                    'Start Selling',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 100,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: _userData?['profileImage'] != null
                                        ? NetworkImage(_userData?['profileImage'])
                                        : null,
                                    backgroundColor: Colors.grey.shade200,
                                    child: _userData?['profileImage'] == null
                                        ? Icon(
                                            Icons.person,
                                            color: Colors.grey.shade400,
                                            size: 80,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        _updateProfileImage();
                                      },
                                      iconSize: 24,
                                      color: Colors.green,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _userData?['email'] ?? 'Email',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSelectableButton('Posts', 0, Icons.post_add),
                              _buildSelectableButton('Images', 1, Icons.image),
                            ],
                          ),
                          Divider(thickness: 2), // Add a long line below the buttons
                          SizedBox(height: 16),
                          Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Text(
                              _userData?['contactNumber'] ?? 'Contact Number',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text(
                              _userData?['address'] ?? 'Address',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.cake),
                            title: Text(
                              _userData?['birthday'] ?? 'Birthday',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text(
                              _userData?['gender'] ?? 'Gender',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.edit, color: Colors.white),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SellerEditDetailsPage(
                                            userData: _userData!,
                                          ),
                                        ),
                                      );
                                    },
                                    label: Text(
                                      'Edit Details',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Divider(thickness: 2), // Add a long line below the Edit Details button
                                if (_selectedButtonIndex == 0) ...[
                                  Text(
                                    'Posts',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ..._userPosts.map((post) => ListTile(
                                        title: Text(post['productName']),
                                        subtitle: Text(
                                            'Available Kilos: ${post['availableKilos']}'),
                                      )),
                                ] else if (_selectedButtonIndex == 1) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                                    child: Text(
                                      'Images',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10), // Add space between the title and the images
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: _userImages.length,
                                    itemBuilder: (context, index) {
                                      return Image.network(
                                        _userImages[index],
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
         backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: badge.Badge(
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

  Widget _buildSelectableButton(String title, int index, IconData iconData) {
    return GestureDetector(
      onTap: () {
        _onButtonTapped(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: _selectedButtonIndex == index ? Colors.green : Colors.grey,
          ),
          Text(
            title,
            style: TextStyle(
              color: _selectedButtonIndex == index ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

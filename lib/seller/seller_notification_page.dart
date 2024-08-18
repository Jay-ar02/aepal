// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_super_parameters, prefer_final_fields, prefer_const_constructors

import 'package:flutter/material.dart';
import 'seller_profile_page.dart'; // Import your profile page here
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;

class SellerNotificationPage extends StatefulWidget {
  const SellerNotificationPage({Key? key}) : super(key: key);

  @override
  _SellerNotificationPageState createState() => _SellerNotificationPageState();
}

class _SellerNotificationPageState extends State<SellerNotificationPage> {
  int _selectedIndex = 1; // Index for 'Notifications'
  bool _loading = false;
  int _unreadNotifications = 0;
  String? _firstName;
  String? _profileImageUrl;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/sellerPage'); // Replace with your route to SellerPage
        break;
      case 1:
        // Stay on Notifications page (current page)
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellerProfilePage()), // Navigate to your profile page
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifications'),
      ),
      body: Column(
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
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: Colors.green))
                : RefreshIndicator(
                    onRefresh: _fetchNotifications,
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: const [
                          NotificationCard(
                            title: 'Product Posted Successfully',
                            message: 'Your product has been posted for bidding successfully. You can now view and manage your product bids.',
                            timestamp: '2024-06-30 10:00 AM',
                          ),
                          // Add more notifications here if needed
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
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
                : const Icon(Icons.person),
            label: _firstName ?? 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 55, 143, 58),
        onTap: _onItemTapped,
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String timestamp;

  const NotificationCard({
    required this.title,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[200], // Set the card color to gray
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

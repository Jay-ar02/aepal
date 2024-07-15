import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'buyer_page.dart'; // Import BuyerPage to use as Home page
import 'buyer_profile_page.dart'; // Import BuyerProfilePage
import 'package:badges/badges.dart' as badges;

class BuyerNotificationPage extends StatefulWidget {
  @override
  _BuyerNotificationPageState createState() => _BuyerNotificationPageState();
}

class _BuyerNotificationPageState extends State<BuyerNotificationPage> {
  int _selectedIndex = 1; // Initially set to 1 (Notifications tab)
  List<DocumentSnapshot> _notifications = [];
  bool _loading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final notifications = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _notifications = notifications.docs;
        _unreadCount =
            notifications.docs.where((doc) => doc['read'] == false).length;
        _loading = false;

        // Mark all notifications as read when loaded
        for (var doc in notifications.docs) {
          if (doc['read'] == false) {
            doc.reference.update({'read': true});
          }
        }
      });
    }
  }

  Future<Map<String, dynamic>> _fetchProductAndOwner(String productId, String message, Timestamp timestamp) async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productDoc.exists) {
        final productData = productDoc.data();
        final ownerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(productData?['userId'])
            .get();

        if (ownerDoc.exists) {
          final ownerData = ownerDoc.data();
          return {
            'productId': productId,
            'productName': productData?['productName'] ?? '',
            'message': message
              .replaceAll('contactNumber', ownerData?['contactNumber'] ?? 'Unknown')
              .replaceAll('firstName', ownerData?['firstName'] ?? 'Unknown')
              .replaceAll('lastName', ownerData?['lastName'] ?? 'Unknown'),
            'timestamp': timestamp,
            'read': false,
          };
        }
      }
    } catch (e) {
      print('Error fetching product data: $e');
    }
    return {
      'productId': '',
      'productName': '',
      'message': '',
      'timestamp': timestamp,
      'read': false,
    };
  }

  void _deleteNotification(DocumentSnapshot notification) async {
    try {
      await notification.reference.delete();
      setState(() {
        _notifications.remove(notification);
      });
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  void _onItemTapped(int index) {
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
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BuyerProfilePage()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Notifications'),
        centerTitle: true,
        actions: <Widget>[
          badges.Badge(
            badgeContent: Text(
              _unreadCount.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            badgeStyle: badges.BadgeStyle(
              // backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _notifications.isEmpty
                  ? Center(child: Text('No notifications available'))
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        final productId = notification['productId'] ?? ''; // Handle missing field
                        final timestamp = notification['timestamp'] as Timestamp?;

                        return Dismissible(
                          key: Key(notification.id),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirm'),
                                  content: Text('Are you sure you want to delete this notification?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('DELETE'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            _deleteNotification(notification);
                          },
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _fetchProductAndOwner(productId, notification['message'] ?? '', timestamp ?? Timestamp.now()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error fetching product data'));
                              } else if (!snapshot.hasData || snapshot.data == null) {
                                return Center(child: Text('Product data not found'));
                              }

                              final data = snapshot.data!;
                              return NotificationCard(
                                productName: data['productName'],
                                message: data['message'],
                                timestamp: data['timestamp'].toDate().toString(),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
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
        selectedItemColor: const Color.fromARGB(255, 55, 143, 58),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String productName;
  final String message;
  final String timestamp;

  const NotificationCard({
    required this.productName,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Date: $timestamp',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

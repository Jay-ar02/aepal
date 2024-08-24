// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'buyer_page.dart';
import 'buyer_profile_page.dart';
import 'package:badges/badges.dart' as badges;

class BuyerNotificationPage extends StatefulWidget {
  @override
  _BuyerNotificationPageState createState() => _BuyerNotificationPageState();
}

class _BuyerNotificationPageState extends State<BuyerNotificationPage> {
  int _selectedIndex = 1;
  List<DocumentSnapshot> _notifications = [];
  bool _loading = true;
  int _unreadCount = 0;
  String? _firstName;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _firstName = userDoc['firstName'] ?? 'Profile';
            _profileImageUrl = userDoc['profileImage'] ?? 'https://via.placeholder.com/150';
          });
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
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _notifications = notifications.docs;
        _unreadCount = notifications.docs.where((doc) => doc['read'] == false).length;
        _loading = false;

        for (var doc in notifications.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null && !data.containsKey('orderReceived')) {
            doc.reference.update({'orderReceived': false});
          }
          if (data != null && doc['read'] == false) {
            doc.reference.update({'read': true});
          }
        }
      });
    }
  }

  Future<Map<String, dynamic>> _fetchProductAndOwner(
      String productId, String message, Timestamp timestamp) async {
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
            'ownerId': productData?['userId'] ?? '',
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
      'ownerId': '',
      'message': '',
      'timestamp': timestamp,
      'read': false,
    };
  }

 Future<void> _rateSeller(String sellerId, double rating, String? comment) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    final sellerDocRef = FirebaseFirestore.instance.collection('users').doc(sellerId);
    final commentsCollectionRef = FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .collection('comments');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot sellerSnapshot = await transaction.get(sellerDocRef);

      if (!sellerSnapshot.exists) {
        throw Exception("Seller not found");
      }

      Map<String, dynamic>? sellerData = sellerSnapshot.data() as Map<String, dynamic>?;
      double currentRating = (sellerData?['rating'] ?? 0.0).toDouble(); // Ensures rating is treated as double
      int totalRatings = (sellerData?['totalRatings'] ?? 0).toInt();  // Ensures totalRatings is treated as int

      double newAverageRating = (currentRating * totalRatings + rating) / (totalRatings + 1);

      transaction.update(sellerDocRef, {
        'rating': newAverageRating,
        'totalRatings': totalRatings + 1,
      });

      if (comment != null && comment.isNotEmpty) {
        final newCommentRef = commentsCollectionRef.doc(); // Create a new document
        transaction.set(newCommentRef, {
          'userId': user.uid,
          'firstName': userData?['firstName'] ?? 'Anonymous',
          'lastName': userData?['lastName'] ?? '',
          'profileImage': userData?['profileImage'] ?? 'https://via.placeholder.com/150',
          'rating': rating,
          'comment': comment,
          'date': Timestamp.now(),
        });
      }
    });

    print("Seller rated and comment stored successfully");
  } catch (e) {
    print("Error rating seller: $e");
  }
}

  void _showRatingDialog(String sellerId) {
    double _rating = 3.0;
    TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Rate Seller'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select Rating'),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow[800],
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(labelText: 'Leave a comment (optional)'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                TextButton(
                  onPressed: () async {
                    await _rateSeller(sellerId, _rating, _commentController.text);
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOrderReceivedDialog(String sellerId, VoidCallback onOrderReceived) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Order'),
          content: Text('Have you received your order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            TextButton(
              onPressed: () {
                onOrderReceived();
                Navigator.of(context).pop();
                _showRatingDialog(sellerId);
              },
              child: Text('Yes'),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ],
        );
      },
    );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            badgeStyle: badges.BadgeStyle(),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              color: Colors.green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.green[100],
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Buyer Mode',
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _notifications.isEmpty
                          ? Center(child: Text('No notifications available'))
                          : ListView.builder(
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                final notification = _notifications[index];
                                final productId = notification['productId'] ?? '';
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
                                          backgroundColor: Colors.white,
                                          title: Text('Confirm'),
                                          content: Text('Are you sure you want to delete this notification?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: Text('CANCEL'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: Text('DELETE'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.green,
                                              ),
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
                                        return Center(child: CircularProgressIndicator(color: Colors.green));
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error fetching product data'));
                                      } else if (!snapshot.hasData || snapshot.data == null) {
                                        return Center(child: Text('Product data not found'));
                                      }

                                      final data = snapshot.data!;
                                      final notificationData = notification.data() as Map<String, dynamic>?;

                                      return NotificationCard(
                                        productName: data['productName'],
                                        message: data['message'],
                                        timestamp: data['timestamp'].toDate().toString(),
                                        sellerId: data['ownerId'],
                                        showOrderReceivedButton: data['message'].contains('you are the winner of the bidding'),
                                        onOrderReceived: () => _showOrderReceivedDialog(
                                          data['ownerId'],
                                          () {
                                            setState(() {
                                              notification.reference.update({'orderReceived': true});
                                            });
                                          },
                                        ),
                                        orderReceived: notificationData?.containsKey('orderReceived') == true 
                                            ? notificationData!['orderReceived'] 
                                            : false,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
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
            icon: badges.Badge(
              showBadge: _unreadCount > 0,
              badgeContent: Text(
                _unreadCount.toString(),
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

class NotificationCard extends StatelessWidget {
  final String productName;
  final String message;
  final String timestamp;
  final String sellerId;
  final bool showOrderReceivedButton;
  final VoidCallback onOrderReceived;
  final bool orderReceived;

  const NotificationCard({
    required this.productName,
    required this.message,
    required this.timestamp,
    required this.sellerId,
    required this.showOrderReceivedButton,
    required this.onOrderReceived,
    this.orderReceived = false, // Default value set to false
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
            if (showOrderReceivedButton && !orderReceived) ...[
              SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: onOrderReceived,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Order Received?',
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
              ),
            ],
            if (orderReceived) ...[
              SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: Text(
                    'Order Received!',
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

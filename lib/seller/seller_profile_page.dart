// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_to_list_in_spreads

import 'package:aepal/buyer/buyer_page.dart';
import 'package:aepal/seller/sales_transaction_history_page.dart';
import 'package:aepal/seller/seller_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'seller_edit_details_page.dart';
import 'seller_comments_page.dart'; 

class SellerProfilePage extends StatefulWidget {
  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  int _selectedIndex = 2;
  int _selectedButtonIndex = 0;
  User? _currentUser;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userPosts = [];
  List<Map<String, dynamic>> _farmLogs = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchUserData();
    _fetchUserPosts();
    _fetchFarmLogs();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
        });
      }
    }
  }

  Future<void> _fetchUserPosts() async {
    if (_currentUser != null) {
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('userId', isEqualTo: _currentUser!.uid)
          .get();
      setState(() {
        _userPosts = postsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _fetchFarmLogs() async {
    if (_currentUser != null) {
      QuerySnapshot logsSnapshot = await FirebaseFirestore.instance
          .collection('farmLogs')
          .where('userId', isEqualTo: _currentUser!.uid)
          .get();
      setState(() {
        _farmLogs = logsSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'activity': data['activity'] ?? 'No activity',
            'description': data['description'] ?? 'No description',
            'timestamp': data['timestamp'] ?? Timestamp.now(),
            'id': doc.id,
          };
        }).toList();
      });
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _fetchUserData(),
      _fetchUserPosts(),
      _fetchFarmLogs(),
    ]);
  }

   void _addFarmLog(String activity, String description) async {
    if (_currentUser != null) {
      DocumentReference newLog = await FirebaseFirestore.instance
          .collection('farmLogs')
          .add({
        'userId': _currentUser!.uid,
        'activity': activity,
        'description': description,
        'timestamp': Timestamp.now(),
      });
      setState(() {
        _farmLogs.add({
          'activity': activity,
          'description': description,
          'timestamp': Timestamp.now(),
          'id': newLog.id,
        });
      });
    }
  }

  void _deleteFarmLog(String logId, int index) async {
    await FirebaseFirestore.instance.collection('farmLogs').doc(logId).delete();
    setState(() {
      _farmLogs.removeWhere((log) => log['id'] == logId);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellerPage()),
        );
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/sellerNotifications');
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
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SalesTransactionHistoryPage()),
        );
      }
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
                    Stack(
                      children: [
                        Container(
                          height: 220,
                          color: Colors.green,
                        ),
                        Positioned(
                          top: 16,
                          left: -23, 
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
                                      builder: (context) => BuyerPage()),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shopping_cart, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text(
                                    'Start Buying',
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
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index <
                                                (_userData?['rating'] ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.yellow[600],
                                      );
                                    }),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SellerCommentsPage(
                                                  userId: _currentUser!.uid),
                                        ),
                                      );
                                    },
                                    child: Text('View Comments >'),
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
                              _buildSelectableButton('FarmLog', 1, Icons.book),
                              _buildSelectableButton('History', 2, Icons.history),
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
                                  Text(
                                    'FarmLog',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ..._farmLogs.map((log) {
                                    return Card(
                                      color: Colors.white, // Set the background color to white
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log['activity'] ?? 'No activity',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              log['description'] ?? 'No description',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              log['timestamp'] != null
                                                  ? DateFormat('MM/dd/yyyy hh:mm a').format(
                                                      (log['timestamp'] as Timestamp).toDate(),
                                                    )
                                                  : 'No Date & Time',
                                              style: TextStyle(fontSize: 14, color: Colors.grey),
                                            ),
                                            SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: IconButton(
                                                icon: Icon(Icons.delete, color: Colors.red),
                                                onPressed: () {
                                                  _showDeleteConfirmationDialog(
                                                      context, log['id'], log['activity']);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: Icon(Icons.add, color: Colors.white),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () => _showAddLogDialog(context),
                                      label: Text(
                                        'Add Farm Activity',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ] else if (_selectedButtonIndex == 2) ...[
                                  Center(
                                    child: CircularProgressIndicator(),
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
      bottomNavigationBar: _userData == null
          ? CircularProgressIndicator()
          : BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notifications',
                ),
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    backgroundImage: _userData?['profileImage'] != null
                        ? NetworkImage(_userData?['profileImage'])
                        : null,
                    radius: 15,
                    backgroundColor: Colors.grey.shade200,
                    child: _userData?['profileImage'] == null
                        ? Icon(Icons.person, color: Colors.grey.shade400)
                        : null,
                  ),
                  label: _userData?['firstName'] ?? 'Profile',
                ),
              ],
            ),
    );
  }

  void _showAddLogDialog(BuildContext context) {
    final activityController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Farm Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: activityController,
                decoration: InputDecoration(
                  labelText: 'Activity',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.blue,
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.blue,
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                _addFarmLog(activityController.text, descriptionController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String logId, String activityName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set the background color to white
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the activity "$activityName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                _deleteFarmLog(logId, _farmLogs.indexWhere((log) => log['id'] == logId));
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
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

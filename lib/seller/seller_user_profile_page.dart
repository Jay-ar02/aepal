// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seller_comments_page.dart';

class SellerUserProfilePage extends StatelessWidget {
  final String userId;

  const SellerUserProfilePage({required this.userId});

  Future<Map<String, dynamic>?> _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Seller not found'));
          }

          final userData = snapshot.data!;
          final double rating = (userData['rating'] ?? 0).toDouble();
          final int totalRatings = userData['totalRatings'] ?? 0;
          final String averageRating = totalRatings > 0 ? (rating / totalRatings).toStringAsFixed(1) : '0.0';

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 220,
                      color: Colors.green,
                    ),
                    Positioned(
                      top: 100,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: userData['profileImage'] != null
                                ? NetworkImage(userData['profileImage'])
                                : null,
                            backgroundColor: Colors.grey.shade200,
                            child: userData['profileImage'] == null
                                ? Icon(
                                    Icons.person,
                                    color: Colors.grey.shade400,
                                    size: 80,
                                  )
                                : null,
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < rating ? Icons.star : Icons.star_border,
                                        color: Colors.yellow[600],
                                      );
                                    }),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    averageRating,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
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
                                      builder: (context) => SellerCommentsPage(userId: userId),
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
                          userData['contactNumber'] ?? 'Contact Number',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text(
                          userData['address'] ?? 'Address',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.cake),
                        title: Text(
                          userData['birthday'] ?? 'Birthday',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                          userData['gender'] ?? 'Gender',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
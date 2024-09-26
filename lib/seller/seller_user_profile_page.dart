// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seller_comments_page.dart';

class SellerUserProfilePage extends StatefulWidget {
  final String userId;

  const SellerUserProfilePage({required this.userId});

  @override
  _SellerUserProfilePageState createState() => _SellerUserProfilePageState();
}

class _SellerUserProfilePageState extends State<SellerUserProfilePage> {
  late Future<Map<String, dynamic>?> userFuture;
  late Future<List<Map<String, dynamic>>> commentsFuture;

  @override
  void initState() {
    super.initState();
    userFuture = _fetchUserData();
    commentsFuture = _fetchComments(); // Fetch comments to calculate average rating
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchComments() async {
    QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.userId)
        .collection('comments')
        .orderBy('date', descending: true)
        .get();

    List<Map<String, dynamic>> comments = [];

    for (var commentDoc in commentsSnapshot.docs) {
      Map<String, dynamic> commentData = commentDoc.data() as Map<String, dynamic>;
      commentData['date'] = (commentData['date'] as Timestamp).toDate().toString();
      comments.add(commentData);
    }

    return comments;
  }

  double _calculateAverageRating(List<Map<String, dynamic>> comments) {
    if (comments.isEmpty) return 0.0;
    double totalRating = 0.0;
    int ratingCount = 0;

    for (var comment in comments) {
      final rating = comment['rating'] as double? ?? 0.0;
      totalRating += rating;
      ratingCount++;
    }

    return ratingCount > 0 ? totalRating / ratingCount : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return Center(child: Text('Seller not found'));
          }

          final userData = userSnapshot.data!;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: commentsFuture,
            builder: (context, commentsSnapshot) {
              if (commentsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!commentsSnapshot.hasData || commentsSnapshot.data!.isEmpty) {
                return Center(child: Text('No comments found'));
              }

              final comments = commentsSnapshot.data!;
              final double averageRating = _calculateAverageRating(comments);
              final int totalRatings = comments.length;

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
                                            index < averageRating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.yellow[600],
                                          );
                                        }),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        averageRating.toStringAsFixed(1),
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
                                          builder: (context) =>
                                              SellerCommentsPage(userId: widget.userId),
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
          );
        },
      ),
    );
  }
}

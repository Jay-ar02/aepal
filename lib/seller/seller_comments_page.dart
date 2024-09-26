// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerCommentsPage extends StatefulWidget {
  final String userId;

  const SellerCommentsPage({required this.userId});

  @override
  _SellerCommentsPageState createState() => _SellerCommentsPageState();
}

class _SellerCommentsPageState extends State<SellerCommentsPage> {
  int selectedRatingFilter = 0; // 0 means all ratings
  late Future<List<Map<String, dynamic>>> commentsFuture;

  @override
  void initState() {
    super.initState();
    commentsFuture = _fetchComments();
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

      // Convert Timestamp to readable format
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
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter by rating:', style: TextStyle(fontSize: 16)),
                DropdownButton<int>(
                  value: selectedRatingFilter,
                  items: [
                    DropdownMenuItem(value: 0, child: Text('All Ratings')),
                    DropdownMenuItem(value: 5, child: Text('5 Stars')),
                    DropdownMenuItem(value: 4, child: Text('4 Stars')),
                    DropdownMenuItem(value: 3, child: Text('3 Stars')),
                    DropdownMenuItem(value: 2, child: Text('2 Stars')),
                    DropdownMenuItem(value: 1, child: Text('1 Star')),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      selectedRatingFilter = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No comments found'));
                }

                // Filter comments based on selected rating
                final comments = snapshot.data!.where((comment) {
                  final rating = comment['rating'] as double? ?? 0.0;
                  return selectedRatingFilter == 0 || rating == selectedRatingFilter;
                }).toList();

                // Calculate the overall average rating
                final overallAverageRating = _calculateAverageRating(snapshot.data!);

                if (comments.isEmpty) {
                  return Center(child: Text('No comments with the selected rating'));
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Overall Rating: ${overallAverageRating.toStringAsFixed(1)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];

                          final rating = comment['rating'] as double? ?? 0.0;
                          final averageRating = rating.toStringAsFixed(1);
                          final commentText = comment['comment'] ?? 'No Comment';
                          final date = comment['date'] ?? 'N/A';
                          final firstName = comment['firstName'] ?? 'Anonymous';
                          final lastName = comment['lastName'] ?? '';
                          final profileImage = comment['profileImage'] ?? 'https://via.placeholder.com/150';

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(profileImage),
                                        radius: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$firstName $lastName',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Row(
                                                children: List.generate(5, (starIndex) {
                                                  return Icon(
                                                    starIndex < rating ? Icons.star : Icons.star_border,
                                                    color: Colors.yellow[800],
                                                    size: 16,
                                                  );
                                                }),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                averageRating,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(commentText),
                                  SizedBox(height: 8),
                                  Text(
                                    'Posted on $date',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

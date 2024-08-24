// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_to_list_in_spreads

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../buyer/buyer_user_profile_page.dart';

class ViewBiddersPage extends StatefulWidget {
  final String productId;

  const ViewBiddersPage({required this.productId});

  @override
  _ViewBiddersPageState createState() => _ViewBiddersPageState();
}

class _ViewBiddersPageState extends State<ViewBiddersPage> {
  String? _winningBidId;
  String? _productName;

  @override
  void initState() {
    super.initState();
    _checkForWinner();
    _fetchProductName();
  }

  Future<void> _checkForWinner() async {
    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    if (productDoc.exists) {
      final productData = productDoc.data() as Map<String, dynamic>;
      setState(() {
        _winningBidId = productData['winningBidId'];
      });
    }
  }

  Future<void> _fetchProductName() async {
    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    if (productDoc.exists) {
      final productData = productDoc.data() as Map<String, dynamic>;
      setState(() {
        _productName = productData['productName'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('View Bidders'),
      ),
      body: RefreshIndicator(
        color: Colors.green,
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
        },
        child: Column(
          children: [
            if (_productName != null)
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Center(
                  child: Text(
                    _productName!,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.productId)
                    .collection('bids')
                    .orderBy('amount', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No bidders for this product.'));
                  }

                  var bids = snapshot.data!.docs;

                  return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: bids.length,
                    itemBuilder: (context, index) {
                      var bidData = bids[index].data() as Map<String, dynamic>;
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(bidData['userId'])
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (userSnapshot.hasError) {
                            return ListTile(title: Text('Error loading bidder info'));
                          }

                          var userData = userSnapshot.data!.data() as Map<String, dynamic>;

                          String rankText;
                          if (index == 0) {
                            rankText = '#1 Highest bidder';
                          } else if (index == 1) {
                            rankText = '#2 Highest bidder';
                          } else if (index == 2) {
                            rankText = '#3 Highest bidder';
                          } else {
                            rankText = '#${index + 1} bidder';
                          }

                          bool isWinner = _winningBidId == bids[index].id;
                          bool hasDelivered = bidData['orderReceived'] ?? false;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuyerUserProfilePage(userId: bidData['userId']),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.grey[200],
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2.0,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: userData['profileImage'] != null
                                              ? NetworkImage(userData['profileImage'])
                                              : null,
                                          child: userData['profileImage'] == null
                                              ? Icon(Icons.person, color: Colors.white)
                                              : null,
                                        ),
                                        SizedBox(width: 16.0),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${userData['firstName']} ${userData['lastName']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(5, (starIndex) {
                                                return Icon(
                                                  starIndex < (userData['rating']?.toInt() ?? 0)  // Cast to int
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.yellow[800],
                                                  size: 16.0,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Text(
                                          rankText,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.0),
                                    Row(
                                      children: [
                                        Text(
                                          '₱',
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          '${bidData['amount']}',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 20.0),
                                        SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            '${userData['address'] ?? 'No address'}',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        isWinner
                                            ? Row(
                                                children: [
                                                  Icon(Icons.emoji_events, color: Colors.orange),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    'Winner',
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : ElevatedButton(
                                                onPressed: _winningBidId != null
                                                    ? null
                                                    : () async {
                                                        bool? confirmAward = await showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: Text('Confirm Award'),
                                                              content: Text(
                                                                'Are you sure you want to award this bid?',
                                                              ),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(context)
                                                                          .pop(false),
                                                                  child: Text(
                                                                    'No',
                                                                    style: TextStyle(
                                                                      color: Colors.red,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(context)
                                                                          .pop(true),
                                                                  child: Text(
                                                                    'Yes',
                                                                    style: TextStyle(
                                                                      color: Colors.green,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );

                                                        if (confirmAward == true) {
                                                          await _awardBid(
                                                              bids[index].id, bidData, bids);
                                                          setState(() {
                                                            _winningBidId = bids[index].id;
                                                          });
                                                        }
                                                      },
                                                child: Text(
                                                  'Award',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all<Color>(
                                                      _winningBidId != null ? Colors.grey : Colors.green),
                                                  minimumSize: MaterialStateProperty.all<Size>(
                                                      Size(80, 36)),
                                                  shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(18.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 20.0),
                                        SizedBox(width: 8.0),
                                        Text(
                                          '${userData['contactNumber']}',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    if (isWinner)
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: ElevatedButton(
                                          onPressed: hasDelivered
                                              ? null
                                              : () async {
                                                  bool? confirmDelivery = await showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          'Confirm Delivery',
                                                          style: TextStyle(color: Colors.black),
                                                        ),
                                                        content: Text(
                                                            'Has the product been delivered?',
                                                            style: TextStyle(color: Colors.black)),
                                                        backgroundColor: Colors.white,
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(context).pop(false),
                                                            child: Text(
                                                              'No',
                                                              style: TextStyle(color: Colors.red),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(context).pop(true),
                                                            child: Text(
                                                              'Yes',
                                                              style: TextStyle(color: Colors.green),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                                  if (confirmDelivery == true) {
                                                    await _showRatingDialog(
                                                        context, bidData['userId']);
                                                    setState(() {
                                                      bidData['orderReceived'] = true;
                                                    });

                                                    // Store transaction in history
                                                    await _storeTransactionInHistory(bidData, userData);
                                                  }
                                                },
                                          child: Text(
                                            hasDelivered ? 'Product Delivered!' : 'Product Deliver?',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(
                                                hasDelivered ? Colors.grey : Colors.green),
                                            minimumSize: MaterialStateProperty.all<Size>(Size(160, 36)),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
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
    );
  }

  Future<void> _awardBid(String winningBidId, Map<String, dynamic> winningBidData, List<DocumentSnapshot> allBids) async {
    try {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      var productData = productDoc.data() as Map<String, dynamic>;

      DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(productData['userId'])
          .get();
      var ownerData = ownerDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(winningBidData['userId'])
          .collection('notifications')
          .add({
        'productId': widget.productId,
        'message':
            'Congratulations, you are the winner of the bidding for ${productData['productName']}. Please contact ${ownerData['firstName']} ${ownerData['lastName']} at ${ownerData['contactNumber']} for your transaction.',
        'timestamp': Timestamp.now(),
        'read': false,
        'orderReceived': false,
      });

      for (var bid in allBids) {
        var bidData = bid.data() as Map<String, dynamic>;
        if (bid.id != winningBidId) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(bidData['userId'])
              .collection('notifications')
              .add({
            'productId': widget.productId,
            'message':
                'Unfortunately, you did not win the bidding for ${productData['productName']}. Better luck next time!',
            'timestamp': Timestamp.now(),
            'read': false,
          });
        }
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({'winningBidId': winningBidId});

    } catch (e) {
      print('Error awarding bid: $e');
    }
  }

  Future<void> _showRatingDialog(BuildContext context, String buyerId) async {
    double _rating = 3.0;
    TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Rate Buyer'),
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
                    decoration: InputDecoration(
                      labelText: 'Leave a comment (optional)',
                    ),
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
                    await _submitRatingAndComment(buyerId, _rating, _commentController.text);
                    Navigator.of(context).pop();
                    setState(() {
                      // After rating submission, mark the bid as delivered
                      _updateBidAsDelivered(buyerId);
                    });
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

  Future<void> _submitRatingAndComment(String buyerId, double rating, String comment) async {
    try {
      // Get the seller's (product owner's) details
      DocumentSnapshot sellerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc((await FirebaseFirestore.instance.collection('products').doc(widget.productId).get()).data()?['userId'])
          .get();
      var sellerData = sellerDoc.data() as Map<String, dynamic>;

      // Store the rating, comment, and seller's details in the comments collection of the buyer
      await FirebaseFirestore.instance
          .collection('users')
          .doc(buyerId)
          .collection('comments')
          .add({
        'rating': rating,
        'comment': comment.isNotEmpty ? comment : null,
        'date': Timestamp.now(),
        'firstName': sellerData['firstName'] ?? 'Anonymous',
        'lastName': sellerData['lastName'] ?? '',
        'profileImage': sellerData['profileImage'] ?? 'https://via.placeholder.com/150',
      });

      // Update the buyer's average rating
      DocumentSnapshot buyerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(buyerId)
          .get();
      var buyerData = buyerDoc.data() as Map<String, dynamic>;

      double totalRatings = (buyerData['totalRatings'] ?? 0).toDouble();
      double existingRating = (buyerData['rating'] ?? 0).toDouble();
      double newRating = ((existingRating * totalRatings) + rating) / (totalRatings + 1);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(buyerId)
          .update({
        'rating': newRating,
        'totalRatings': totalRatings + 1,
      });
    } catch (e) {
      print('Error submitting rating: $e');
    }
  }

  Future<void> _updateBidAsDelivered(String buyerId) async {
    try {
      // Update the bid as delivered
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('bids')
          .where('userId', isEqualTo: buyerId)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.update({'orderReceived': true});
        }
      });

      // Update UI
      setState(() {
        // Refresh the page to reflect the changes
      });
    } catch (e) {
      print('Error updating bid as delivered: $e');
    }
  }

  Future<void> _storeTransactionInHistory(Map<String, dynamic> bidData, Map<String, dynamic> userData) async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      final productData = productDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('sales_transaction_history').add({
        'productId': widget.productId,
        'buyerId': bidData['userId'],
        'productName': productData['productName'],
        'amount': bidData['amount'],
        'firstName': userData['firstName'],
        'lastName': userData['lastName'],
        'availableKilos': productData['availableKilos'],
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error storing transaction in history: $e');
    }
  }
}

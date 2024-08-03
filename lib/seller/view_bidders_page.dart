import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewBiddersPage extends StatefulWidget {
  final String productId;

  const ViewBiddersPage({required this.productId});

  @override
  _ViewBiddersPageState createState() => _ViewBiddersPageState();
}

class _ViewBiddersPageState extends State<ViewBiddersPage> {
  String? _winningBidId;

  @override
  void initState() {
    super.initState();
    _checkForWinner();
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

                    return Card(
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
                                Text(
                                  '${userData['firstName']} ${userData['lastName']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(width: 8.0),
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
                                  ' ₱',
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
                                                          child: Text('No'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(context)
                                                                  .pop(true),
                                                          child: Text('Yes'),
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
                          ],
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
    );
  }

  Future<void> _awardBid(String winningBidId, Map<String, dynamic> winningBidData, List<DocumentSnapshot> allBids) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      try {
        // Fetch the product and owner details
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

        // Notify the winning bidder
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
        });

        // Notify losing bidders
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

        // Update the product's bid status
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update({'winningBidId': winningBidId});

      } catch (e) {
        print('Error awarding bid: $e');
      }
    }
  }
}

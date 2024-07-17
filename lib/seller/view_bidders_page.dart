// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, deprecated_member_use, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewBiddersPage extends StatelessWidget {
  final String productId;

  const ViewBiddersPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
         backgroundColor: Colors.white,
        title: Text('View Bidders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .collection('bids')
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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowHeight: 48,
              dataRowHeight: 64,
              columns: <DataColumn>[
                DataColumn(
                  label: Text(
                    'Bidder Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Bid Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Contact',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Award',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: bids.map((bid) {
                var bidData = bid.data() as Map<String, dynamic>;
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Text('${bidData['firstName']} ${bidData['lastName']}'),
                    ),
                    DataCell(
                      Text('₱${bidData['amount']}'),
                    ),
                    DataCell(
                      Text(bidData['contactNumber']),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () async {
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
                                        Navigator.of(context).pop(false),
                                    child: Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmAward == true) {
                            await _awardBid(bid.id, bidData);
                          }
                        },
                        child: Text(
                          'Award',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green),
                          minimumSize:
                              MaterialStateProperty.all<Size>(Size(80, 36)),
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
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Future<void> _awardBid(String bidId, Map<String, dynamic> bidData) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      try {
        // Fetch the product and owner details
        DocumentSnapshot productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();
        var productData = productDoc.data() as Map<String, dynamic>;

        DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(productData['userId'])
            .get();
        var ownerData = ownerDoc.data() as Map<String, dynamic>;

        // Send notification to the winning bidder
        await FirebaseFirestore.instance
            .collection('users')
            .doc(bidData['userId']) // The userId from bidData
            .collection('notifications')
            .add({
          'message':
              'Congratulations, you are the winner of the bidding for ${productData['productName']}. Please contact ${ownerData['firstName']} ${ownerData['lastName']} at ${ownerData['contactNumber']} for your transaction.',
          'timestamp': Timestamp.now(),
          'read': false,
        });

        // Optionally, update the product's bid status or perform any other necessary actions
        // ...

      } catch (e) {
        print('Error awarding bid: $e');
      }
    }
  }
}

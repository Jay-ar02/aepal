// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_to_list_in_spreads

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesTransactionHistoryPage extends StatelessWidget {
  const SalesTransactionHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sales_transaction_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No transaction history found.'));
          }

          var transactions = snapshot.data!.docs;

          // Calculate total sales
          double totalSales = transactions.fold(0.0, (sum, doc) {
            var data = doc.data() as Map<String, dynamic>;
            return sum + (data['amount'] as num).toDouble();
          });

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: transactions.length + 2, // +2 for the "Total Sales" card and the "Transaction History" label
            itemBuilder: (context, index) {
              if (index == 0) {
                // Total Sales Card
                return Card(
                  color: Colors.green[400],
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2.0,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Total Sales: ₱${totalSales.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              } else if (index == 1) {
                // Transaction History Label
                return Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
                  child: Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                );
              } else {
                // Transaction History Cards
                var transactionData = transactions[index - 2].data() as Map<String, dynamic>;

                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2.0,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transactionData['productName'] ?? 'Product Name',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Buyer: ${transactionData['firstName']} ${transactionData['lastName']}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Amount: ₱${transactionData['amount']}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Bought ${transactionData['availableKilos']} Kilos',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(transactionData['timestamp'].toDate())}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16.0,
                        top: 80.0,
                        child: Row(
                          children: [
                            Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.0),
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
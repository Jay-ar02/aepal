import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'buyer_user_profile_page.dart';

class BuyerSearchPage extends StatefulWidget {
  final String initialQuery;

  BuyerSearchPage({required this.initialQuery});

  @override
  _BuyerSearchPageState createState() => _BuyerSearchPageState();
}

class _BuyerSearchPageState extends State<BuyerSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final StreamController<String> _searchStreamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery;
    _controller.addListener(() {
      _onSearchChanged(_controller.text);
    });
    _onSearchChanged(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchStreamController.close();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchStreamController.add(query);
  }

  Stream<List<Map<String, dynamic>>> _search(String query) async* {
    if (query.isEmpty) {
      yield [];
    } else {
      final userResults = await FirebaseFirestore.instance
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final productResults = await FirebaseFirestore.instance
          .collection('products')
          .where('productName', isGreaterThanOrEqualTo: query)
          .where('productName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final municipalityResults = await FirebaseFirestore.instance
          .collection('addresses')
          .where('municipality', isGreaterThanOrEqualTo: query)
          .where('municipality', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final combinedResults = [
        ...userResults.docs.map((doc) => {
              'type': 'user',
              'firstName': doc['firstName'],
              'lastName': doc['lastName'],
              'userId': doc.id,
              'profileImage': doc['profileImage'],
            }),
        ...productResults.docs.map((doc) => {
              'type': 'product',
              'productName': doc['productName'],
            }),
        ...municipalityResults.docs.map((doc) => {
              'type': 'municipality',
              'municipality': doc['municipality'],
            }),
      ];

      yield combinedResults;
    }
  }

  void _navigateToBuyerPage(String productName) {
    Navigator.pop(context, productName);
  }

  void _navigateToMunicipalityPage(String municipality) {
    Navigator.pop(context, {'municipality': municipality});
  }

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyerUserProfilePage(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Search here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          StreamBuilder<String>(
            stream: _searchStreamController.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(); // Hide suggestions when search query is empty
              }

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: _search(snapshot.data!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.green));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final results = snapshot.data ?? [];
                  if (results.isEmpty) {
                    return Center(child: Text('No results found'));
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        if (result['type'] == 'user') {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: result['profileImage'] != null
                                  ? NetworkImage(result['profileImage'])
                                  : null,
                              backgroundColor: Colors.grey.shade200,
                              child: result['profileImage'] == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.grey.shade400,
                                    )
                                  : null,
                            ),
                            title: Text('${result['firstName']} ${result['lastName']}'),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              _navigateToUserProfile(result['userId']);
                            },
                          );
                        } else if (result['type'] == 'product') {
                          return ListTile(
                            title: Text(result['productName']),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              _navigateToBuyerPage(result['productName']);
                            },
                          );
                        } else {
                          return ListTile(
                            title: Text(result['municipality']),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              _navigateToMunicipalityPage(result['municipality']);
                            },
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
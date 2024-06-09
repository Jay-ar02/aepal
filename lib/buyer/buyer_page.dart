import 'package:flutter/material.dart';
import 'package:aepal/buyer/product_details_page.dart'; 

class BuyerPage extends StatelessWidget {
  const BuyerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
      appBar: AppBar(
  title: const Text('Product Lists'),
  backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.of(context).pop(),
  ),
  actions: <Widget>[
    // Temporarily disabled search icon
    SizedBox.shrink(),
  ],
),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Bidding Items',
              style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.black),
            ),
          ),
          _buildFacebookPostCard('banana.jpg', 'Banana', 'Current Bid: \$150', 'Place Bid'),
          // You can add more _buildFacebookPostCard calls here for additional items
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Color.fromARGB(255, 2, 2, 2)), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications, color: Color.fromARGB(255, 0, 0, 0)), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle, color: Color.fromARGB(255, 0, 0, 0)), label: 'Profile'),
        ],
        selectedItemColor: Colors.amber[800], // Highlight selected item
        unselectedItemColor: Colors.grey, // Distinguish unselected items
        // Note: Since this is a StatelessWidget, we cannot handle taps on BottomNavigationBar items directly here.
        // Consider converting to StatefulWidget if you need to handle navigation.
      ),
    );
  }

  Widget _buildFacebookPostCard(String imageName, String title, String subtitle, String action) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,
      child: InkWell(
        onTap: () {}, // Optional: Handle tap on card
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), // Apply border radius only to the top corners
              child: Image.asset(
                'assets/images/$imageName',
                fit: BoxFit.cover, // Cover the area with the image
                height: 150, // Fixed height for the image
                width: double.infinity, // Full width
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle),
                  Text(action, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
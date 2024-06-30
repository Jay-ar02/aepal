import 'package:flutter/material.dart';
import 'seller_page.dart';
import 'seller_profile_page.dart'; // Import your profile page here

class SellerNotificationPage extends StatefulWidget {
  const SellerNotificationPage({Key? key}) : super(key: key);

  @override
  _SellerNotificationPageState createState() => _SellerNotificationPageState();
}

class _SellerNotificationPageState extends State<SellerNotificationPage> {
  int _selectedIndex = 1; // Index for 'Notifications'

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle navigation here based on index
      switch (index) {
        case 0:
          // Navigate to SellerPage
          Navigator.pushNamed(context, '/sellerPage'); // Replace with your route to SellerPage
          break;
        case 1:
          // Stay on Notifications page (current page)
          break;
        case 2:
          // Navigate to Profile page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SellerProfilePage()), // Navigate to your profile page
          );
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            NotificationCard(
              title: 'Product Posted Successfully',
              message: 'Your product has been posted for bidding successfully. You can now view and manage your product bids.',
              timestamp: '2024-06-30 10:00 AM',
            ),
            // Add more notifications here if needed
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 55, 143, 58),
        onTap: _onItemTapped,
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String timestamp;

  NotificationCard({
    required this.title,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[200], // Set the card color to gray
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timestamp,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

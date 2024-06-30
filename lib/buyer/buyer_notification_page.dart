import 'package:flutter/material.dart';
import 'buyer_page.dart'; // Import BuyerPage to use as Home page
import 'buyer_profile_page.dart'; // Import BuyerProfilePage

class BuyerNotificationPage extends StatefulWidget {
  @override
  _BuyerNotificationPageState createState() => _BuyerNotificationPageState();
}

class _BuyerNotificationPageState extends State<BuyerNotificationPage> {
  int _selectedIndex = 1; // Set default index to Notifications

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BuyerPage()),
        );
        break;
      case 1:
        // Current page, do nothing
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BuyerProfilePage()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            NotificationCard(
              productName: 'Organic Carrots',
              message: 'Congratulations! You have won the bid for Organic Carrots. Please contact the farmer at this number ',
              phoneNumber: '09212189555',
              date: 'June 30, 2024',
            ),
            SizedBox(height: 16),
            NotificationCard(
              productName: 'Premium Rice',
              message: 'You were not selected for the bid on Premium Rice. Better luck next time!',
              phoneNumber: '',
              date: 'June 29, 2024',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        selectedItemColor: Color.fromARGB(255, 55, 143, 58),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String productName;
  final String message;
  final String phoneNumber;
  final String date;

  NotificationCard({
    required this.productName,
    required this.message,
    required this.phoneNumber,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200], // Set the color of the card to light gray
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  if (phoneNumber.isNotEmpty) 
                    TextSpan(
                      text: phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

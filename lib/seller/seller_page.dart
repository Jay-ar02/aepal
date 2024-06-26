import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'seller_notification_page.dart';
import 'seller_profile_page.dart'; // Import the profile page
import 'view_bidders_page.dart'; // Import the view bidders page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SellerPage(),
      routes: {
        '/sellerNotifications': (context) => SellerNotificationPage(),
        '/sellerProfile': (context) => SellerProfilePage(),
        '/viewBidders': (context) => ViewBiddersPage(), // Add route for ViewBiddersPage
      },
    );
  }
}

class SellerPage extends StatefulWidget {
  @override
  _SellerPageState createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Handle Home tab
        // You can add a navigation logic for the Home tab if needed
        break;
      case 1:
        // Handle Notifications tab
        Navigator.pushNamed(context, '/sellerNotifications');
        break;
      case 2:
        // Handle Profile tab
        Navigator.pushNamed(context, '/sellerProfile');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Handle filter action
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'MY PRODUCTS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.65,
              ),
              itemCount: 2, // Adjusted to show only two products
              itemBuilder: (context, index) {
                return ProductCard(
                  sellerName: index % 2 == 0 ? 'TINDAHAN NI KUTING' : 'TINDAHAN NI KUTING',
                  imageUrl: index == 0
                      ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRRZk-5pv0ePdI4I1dhrwh2eBEGYeMMipOQxA&s'
                      : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSD6tAyNupJFSMx15pu6sFxU1VUZivO8Jm3jg&s',
                  title: index == 0 ? 'CARROTS' : 'RICE',
                  location: index == 0 ? 'Legazpi, Albay' : 'Daraga, Albay',
                  availableKgs: index == 0 ? 50 : 100,
                  timeDuration: Duration(hours: 1), // Adding time duration (1 hour)
                  onPressed: () {
                    Navigator.pushNamed(context, '/viewBidders'); // Updated to use the route
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
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

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black), // Default border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black), // Border color when focused
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              'SEARCH',
              style: TextStyle(color: Colors.black), // Text color set to black
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String sellerName;
  final String imageUrl;
  final String title;
  final String location;
  final int availableKgs;
  final Duration timeDuration; // New parameter for time duration
  final VoidCallback onPressed;

  ProductCard({
    required this.sellerName,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.availableKgs,
    required this.timeDuration,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle smallFontSize = TextStyle(fontSize: 12);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sellerName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(location, style: smallFontSize.copyWith(fontStyle: FontStyle.italic)),
                  Text('AVAILABLE KLS.: $availableKgs', style: smallFontSize),
                  Row(
      children: [
        Text(
          'Time Duration: ',
          style: smallFontSize,
        ),
        Text(
          '${timeDuration.inHours} hr',
          style: smallFontSize.copyWith(
            color: timeDuration.inHours == 1 ? Colors.red : Colors.black,
          ),
        ),
      ],
    ),
                  SizedBox(height: 8), // Adjusted spacing for better layout
                  ElevatedButton(
                    onPressed: onPressed,
                    child: Text(
                      'VIEW BIDDERS',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 30)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

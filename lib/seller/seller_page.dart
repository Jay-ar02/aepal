import 'package:aepal/seller/view_bidders_page.dart';
import 'package:flutter/material.dart';
import 'add_product_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SellerPage(),
    );
  }
}

class SellerPage extends StatelessWidget {
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
)
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
              itemCount: 4,
              itemBuilder: (context, index) {
                return ProductCard(
                  sellerName: index % 2 == 0? 'TINDAHAN NI KUTING' : 'TINDAHAN NI KUTING',
                  imageUrl: index == 0
                     ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRRZk-5pv0ePdI4I1dhrwh2eBEGYeMMipOQxA&s'
                      : index == 1
                         ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSD6tAyNupJFSMx15pu6sFxU1VUZivO8Jm3jg&s'
                          : index == 2
                            ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTENdraYu3J3Niy7eeN_EzUXmAWS9aFQ4SC_g&s'
                              : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGJ_kSlbXozilHNrJkajdf49S6VOQfsmaWqg&s',
                  title: index == 0
                    ? 'CARROTS'
                      : index == 1
                        ? 'RICE'
                          : index == 2
                            ? 'KAMOTE'
                              : 'SAGING',
                  location: index == 0 || index == 2
                    ? 'Legazpi, Albay'
                      : 'Daraga, Albay',
                  availableKgs: index == 0
                    ? 50
                      : index == 1
                        ? 100
                          : index == 2
                            ? 0
                              : 0,
                  timeHarvested: index == 0
                    ? '7:00 A.M'
                      : index == 1
                        ? '10:00 A.M'
                          : 'NONE',
                  isBiddingSoon: index == 2 || index == 3,
                );
              },
            ),
          ),
        ],
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
                ),
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            child: Text('SEARCH'),
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
  final String timeHarvested;
  final bool isBiddingSoon;

  ProductCard({
    required this.sellerName,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.availableKgs,
    required this.timeHarvested,
    required this.isBiddingSoon,
  });

  @override
  Widget build(BuildContext context) {
    // Define a smaller font size style for non-bold text
    TextStyle smallFontSize = TextStyle(fontSize: 12); // Adjust the size as needed

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
                // Icon(Icons.bookmark, color: Colors.black),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(1)),
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
                  Text('TIME HARVESTED: $timeHarvested', style: smallFontSize), 
                  SizedBox(height: 5),
                  isBiddingSoon
                    ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                'BIDDING SOON',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                          ),
                        )
                        : Center(
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewBiddersPage()),
      );
    },
    child: Text('VIEW BIDDERS'),
    style: ElevatedButton.styleFrom(
      minimumSize: Size(100, 30),
      backgroundColor: Colors.green,
      textStyle: TextStyle(color: Colors.white, fontSize: 12),
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

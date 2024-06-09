import 'package:flutter/material.dart';
import 'buyer/buyer_page.dart';
import 'seller/seller_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to AE-Pal'),
            const SizedBox(height: 20), // Adds some space between the text and the buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to Seller Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerPage()), // Make sure to define SellerPage widget
                );
              },
              child: const Text('I am a Seller'),
            ),
            const SizedBox(height: 10), // Adds some space between the buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to Buyer Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyerPage()), // Make sure to define BuyerPage widget
                );
              },
              child: const Text('I am a Buyer'),
            ),
          ],
        ),
      ),
    );
  }
}
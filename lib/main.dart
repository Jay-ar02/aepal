// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'seller/seller_page.dart';
import 'seller/seller_notification_page.dart';
import 'buyer/buyer_notification_page.dart';
import 'seller/view_bidders_page.dart'; // Import ViewBiddersPage
import 'buyer/buyer_page.dart';
import 'buyer/buyer_profile_page.dart';
import 'seller/seller_profile_page.dart';
import 'seller/add_address_page.dart';
import 'seller/add_product_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aepal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set initial route to '/'
      routes: {
        '/': (context) => SplashPage(),
        '/buyerProfile': (context) => BuyerProfilePage(),
        '/sellerPage': (context) => SellerPage(),
        '/sellerNotifications': (context) => SellerNotificationPage(),
        '/buyerNotifications': (context) => BuyerNotificationPage(),
        '/buyerPage': (context) => BuyerPage(),
        '/sellerProfile': (context) => SellerProfilePage(),
        '/addAddress': (context) => AddAddressPage(),
        '/addProduct': (context) => AddProductPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/viewBidders') {
          final args = settings.arguments as Map<String, dynamic>;
          final productId = args['productId'] as String;
          return MaterialPageRoute(
            builder: (context) => ViewBiddersPage(productId: productId),
          );
        }
        return null; // Let `MaterialApp` handle unknown routes
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Image.asset('assets/images/1.png', height: 150),
            const Text(
              'AE-PAL',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        side: const BorderSide(color: Colors.black),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text(
                        'LOG IN',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: Color.fromARGB(255, 55, 143, 58),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text(
                        'REGISTER',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:aepal/main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  // Updated the splash screen duration to 3 seconds
  startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    Timer(duration, route);
  }

  // Navigate to the HomePage
  route() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Ensure horizontal centering
          children: <Widget>[
            Image.asset(
              'assets/images/1.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover, // Ensure image covers the box
            ),
            const SizedBox(height: 20),
            const Text(
              'AE-PAL', // Updated to match the app's title
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Matching the title color
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 55, 143, 58)), // Color to match the theme
            ),
          ],
        ),
      ),
    );
  }
}

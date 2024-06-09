import 'package:flutter/material.dart';
import 'dart:async'; 

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

 startSplashScreen() async {
    var duration = const Duration(seconds: 10);
    return Timer(duration, route);
 }

 route() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NextScreen()));
 }

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/aepal.png', width: 200, height: 200),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
 }
}

class NextScreen extends StatelessWidget {
 const NextScreen({super.key});

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: const Center(
        child: Text('Next Page!'),
      ),
    );
 }
}

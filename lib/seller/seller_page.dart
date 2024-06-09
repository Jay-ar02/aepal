import 'package:flutter/material.dart';

class SellerPage extends StatelessWidget {
  const SellerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Page'),
      ),
      body: const Center(child: Text('Welcome to the Seller Page')),
    );
  }
}

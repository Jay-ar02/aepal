import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  const ProductDetailsPage({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for contrast
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.blue, // Consistent app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Hero(
                tag: productId,
                child: Image.network('https://example.com/product-image.jpg', width: 300, height: 300, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'ID: $productId',
              style: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.black), // Adjust text color
            ),
            SizedBox(height: 20),
            Text(
              'Product Name',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.black), // Adjust text color
            ),
            SizedBox(height: 10),
            Text(
              'by Seller Name',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.grey), // Adjust text color
            ),
            SizedBox(height: 20),
           ElevatedButton(
  onPressed: () {},
  child: const Text('View Details'),
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Button color
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
  ),
),
          ],
        ),
      ),
    );
  }
}
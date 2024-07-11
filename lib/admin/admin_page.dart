import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isManageUsersClicked = false;

  void _onManageUsersPressed() {
    setState(() {
      _isManageUsersClicked = true;
    });
    // Implement admin-specific functionality here
  }

  void _onManagePostsPressed() {
    setState(() {
      _isManageUsersClicked = false;
    });
    // Implement admin-specific functionality here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 180, // Adjusted width to make the buttons wider
                height: 50, // Set the height to make the buttons rectangular
                child: ElevatedButton(
                  onPressed: _onManageUsersPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isManageUsersClicked ? Colors.green : Colors.white, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Rectangle shape
                    ),
                  ),
                  child: Text(
                    'Manage Users',
                    style: TextStyle(color: _isManageUsersClicked ? Colors.white : Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Space between the buttons
              SizedBox(
                width: 200, // Adjusted width to make the buttons wider
                height: 50, // Set the height to make the buttons rectangular
                child: ElevatedButton(
                  onPressed: _onManagePostsPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isManageUsersClicked ? Colors.green : Colors.white, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Rectangle shape
                    ),
                  ),
                  child: Text(
                    'Manage Posts',
                    style: TextStyle(color: !_isManageUsersClicked ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: AdminPage()));
}

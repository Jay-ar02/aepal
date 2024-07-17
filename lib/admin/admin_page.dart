// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, use_build_context_synchronously, prefer_const_constructors, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AdminPage(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isManageUsersClicked = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  void _onManageUsersPressed() {
    setState(() {
      _isManageUsersClicked = true;
      _searchText = "";
      _searchController.clear();
    });
  }

  void _onManagePostsPressed() {
    setState(() {
      _isManageUsersClicked = false;
      _searchText = "";
      _searchController.clear();
    });
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchText = text;
    });
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Delete the user's posts first
      final postsQuery = FirebaseFirestore.instance
          .collection('products')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in (await postsQuery).docs) {
        await _deletePost(doc.id);
      }

      // Delete the user from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Optionally, if the user is also in Firebase Authentication
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final authUserId = userDoc.data()?['authUserId'] as String?;

      if (authUserId != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.uid == authUserId) {
          await user.delete();
        } else {
          // Handle case for re-authentication if needed
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<bool> _onWillPop() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return Future.value(true);
    } else {
      _showExitConfirmationDialog();
      return Future.value(false);
    }
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('Yes', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(String id, String type, Future<void> Function(String) deleteFunction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text('Delete $type'),
        content: Text('Are you sure you want to delete this $type?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteFunction(id);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserEnabledStatus(String userId, bool isEnabled) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isEnabled': isEnabled,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${isEnabled ? 'enabled' : 'disabled'} successfully')),
      );
    } catch (e) {
      print('Error toggling user enabled status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Admin'),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _showLogoutConfirmationDialog,
            ),
          ],
        ),
        body: RefreshIndicator(
          color: Colors.green,
          onRefresh: () async {
            setState(() {}); // This will rebuild the widget to refresh the data
          },
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchTextChanged,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: _isManageUsersClicked ? 'Search Users' : 'Search Posts',
                    labelStyle: TextStyle(color: Colors.black), // Default text color
                    floatingLabelStyle: TextStyle(color: Colors.black), // Color when focused
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 180,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onManageUsersPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isManageUsersClicked ? Colors.green : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        'Manage Users',
                        style: TextStyle(color: _isManageUsersClicked ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onManagePostsPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isManageUsersClicked ? Colors.green : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
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
              const SizedBox(height: 20),
              Expanded(
                child: _isManageUsersClicked
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)));
                          }
                          if (snapshot.hasError) {
                            return const Center(child: Text('Error fetching users'));
                          }
                          final users = snapshot.data?.docs ?? [];
                          final filteredUsers = users.where((user) {
                            final userData = user.data() as Map<String, dynamic>;
                            final firstName = userData['firstName']?.toString().toLowerCase() ?? '';
                            final lastName = userData['lastName']?.toString().toLowerCase() ?? '';
                            final email = userData['email']?.toString().toLowerCase() ?? '';
                            final searchText = _searchText.toLowerCase();
                            return firstName.contains(searchText) ||
                                lastName.contains(searchText) ||
                                email.contains(searchText);
                          }).toList();

                          return ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final userData = user.data() as Map<String, dynamic>;
                              final userId = user.id;
                              final firstName = userData['firstName'] ?? 'Unknown';
                              final lastName = userData['lastName'] ?? 'Unknown';
                              final email = userData['email'] ?? 'Unknown';
                              final isEnabled = userData['isEnabled'] ?? true;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                color: Colors.grey[100], // Set the background color to a lighter gray
                                child: ListTile(
                                  title: Text('$firstName $lastName'),
                                  subtitle: Text(email),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isEnabled ? Icons.toggle_on : Icons.toggle_off,
                                          color: isEnabled ? Colors.green : Colors.red,
                                        ),
                                        onPressed: () {
                                          _toggleUserEnabledStatus(userId, !isEnabled);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(userId, 'user', _deleteUser);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('products').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)));
                          }
                          if (snapshot.hasError) {
                            return const Center(child: Text('Error fetching posts'));
                          }
                          final posts = snapshot.data?.docs ?? [];
                          final filteredPosts = posts.where((post) {
                            final postData = post.data() as Map<String, dynamic>;
                            final productName = postData['productName']?.toString().toLowerCase() ?? '';
                            final address = postData['address']?.toString().toLowerCase() ?? '';
                            final searchText = _searchText.toLowerCase();
                            return productName.contains(searchText) || address.contains(searchText);
                          }).toList();

                          return ListView.builder(
                            itemCount: filteredPosts.length,
                            itemBuilder: (context, index) {
                              final post = filteredPosts[index];
                              final postData = post.data() as Map<String, dynamic>;
                              final productName = postData['productName'] ?? 'Unknown';
                              final imageUrl = postData['imageUrl'] ?? '';
                              final address = postData['address'] ?? 'Unknown';
                              final userId = postData['userId'] ?? '';

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)));
                                  }
                                  if (userSnapshot.hasError) {
                                    return const Center(child: Text('Error fetching user'));
                                  }
                                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                                  final firstName = userData?['firstName'] ?? 'Unknown';
                                  final lastName = userData?['lastName'] ?? 'Unknown';

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                    color: Colors.grey[100], // Set the background color to a lighter gray
                                    child: ListTile(
                                      title: Text(productName),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('$firstName $lastName'),
                                          Text(address),
                                        ],
                                      ),
                                      leading: imageUrl.isNotEmpty
                                          ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                                          : const Icon(Icons.image, size: 50),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(post.id, 'post', _deletePost);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

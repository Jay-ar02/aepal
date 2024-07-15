import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../login_page.dart'; // Import LoginPage

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
  bool _isManageUsersClicked = false;

  void _onManageUsersPressed() {
    setState(() {
      _isManageUsersClicked = true;
    });
  }

  void _onManagePostsPressed() {
    setState(() {
      _isManageUsersClicked = false;
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
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(postId).delete();
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

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('Yes'),
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
        title: Text('Delete $type'),
        content: Text('Are you sure you want to delete this $type?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteFunction(id);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: Column(
        children: [
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
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching users'));
                      }
                      final users = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final userData = user.data() as Map<String, dynamic>;
                          final userId = user.id;
                          final firstName = userData['firstName'] ?? 'Unknown';
                          final lastName = userData['lastName'] ?? 'Unknown';
                          final email = userData['email'] ?? 'Unknown';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            color: Colors.grey[100], // Set the background color to a lighter gray
                            child: ListTile(
                              title: Text('$firstName $lastName'),
                              subtitle: Text(email),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(userId, 'user', _deleteUser);
                                },
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
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching posts'));
                      }
                      final posts = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final postData = post.data() as Map<String, dynamic>;
                          final productName = postData['productName'] ?? 'Unknown';
                          final imageUrl = postData['imageUrl'] ?? '';
                          final address = postData['address'] ?? 'Unknown';
                          final userId = postData['userId'] ?? '';

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (userSnapshot.hasError) {
                                return const Center(child: Text('Error fetching user'));
                              }

                              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                // User no longer exists, so we delete the post.
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _deletePost(post.id);
                                });
                                return SizedBox.shrink();
                              }

                              final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                              final firstName = userData?['firstName'] ?? 'Unknown';
                              final lastName = userData?['lastName'] ?? 'Unknown';

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                color: Colors.grey[100], // Set the background color to a lighter gray
                                child: ListTile(
                                  leading: imageUrl.isNotEmpty
                                      ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                                      : const Icon(Icons.image, size: 60),
                                  title: Text(productName),
                                  subtitle: Text('$address\nby $firstName $lastName'),
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
    );
  }
}

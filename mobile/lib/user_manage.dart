import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for iOS-style back button
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _currentUserId = user.uid;
        });

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(_currentUserId).get();

        setState(() {
          _currentUserRole =
              userDoc.exists ? (userDoc['role'] ?? 'user') : 'user';
        });
      }
    } catch (e) {
      print('Error fetching current user: $e');
      setState(() {
        _currentUserRole = 'user';
      });
    }
  }

  void _showUserOptionsBottomSheet(DocumentSnapshot user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user['name'] ?? 'Unknown User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton(
                      icon: Icons.people_alt_outlined,
                      label: 'Change Role',
                      onTap: () {
                        Navigator.pop(context);
                        _changeUserRole(user);
                      },
                    ),
                    _buildOptionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete User',
                      color: Colors.red[800],
                      onTap: () {
                        Navigator.pop(context);
                        _confirmDeleteUser(user);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.green[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _changeUserRole(DocumentSnapshot user) {
    String currentRole = user['role'] ?? 'user';
    String newRole = currentRole == 'admin' ? 'user' : 'admin';

    if (_currentUserRole == 'admin') {
      _updateUserRole(user.id, newRole);
    } else {
      _showUnauthorizedMessage();
    }
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });
      _showSuccessMessage('User role updated to $newRole');
    } catch (e) {
      print('Error updating user role: $e');
      _showErrorMessage('Failed to update user role');
    }
  }

  void _confirmDeleteUser(DocumentSnapshot user) {
    if (_currentUserRole == 'admin') {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Delete User'),
              content: Text('Are you sure you want to delete ${user['name']}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteUser(user);
                  },
                  child: Text('Delete'),
                ),
              ],
            ),
      );
    } else {
      _showUnauthorizedMessage();
    }
  }

  Future<void> _deleteUser(DocumentSnapshot user) async {
    try {
      await _firestore.collection('users').doc(user.id).delete();
      _showSuccessMessage('User deleted successfully');
    } catch (e) {
      print('Error deleting user: $e');
      _showErrorMessage('Failed to delete user');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green[800]),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[800]),
    );
  }

  void _showUnauthorizedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Only admins can perform this action'),
        backgroundColor: Colors.red[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            (_currentUserRole == 'admin')
                ? _firestore.collection('users').snapshots()
                : _firestore
                    .collection('users')
                    .where(FieldPath.documentId, isEqualTo: _currentUserId)
                    .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: Colors.green[800]),
            );
          }

          var users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              String currentRole = user['role'] ?? 'user';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.person, color: Colors.green[800]),
                  ),
                  title: Text(
                    user['name'] ?? 'Unknown User',
                    style: TextStyle(
                      color: Colors.green[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Role: $currentRole',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                  trailing:
                      _currentUserRole == 'admin'
                          ? IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.green[800],
                            ),
                            onPressed: () => _showUserOptionsBottomSheet(user),
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackManagementPage extends StatefulWidget {
  const FeedbackManagementPage({Key? key}) : super(key: key);

  @override
  _FeedbackManagementPageState createState() => _FeedbackManagementPageState();
}

class _FeedbackManagementPageState extends State<FeedbackManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _responseController = TextEditingController();
  bool _isAdminChecked = false;
  bool _isAdminUser = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  // Improved admin check using role instead of isAdmin
  Future<void> _checkAdminStatus() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isAdminChecked = true;
        _isAdminUser = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      bool isAdmin = false;
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        // Check for admin role
        isAdmin = userData != null && userData['role'] == "admin";
      }

      if (mounted) {
        setState(() {
          _isAdminChecked = true;
          _isAdminUser = isAdmin;
        });
      }
    } catch (e) {
      print('Error checking admin status: $e');
      if (mounted) {
        setState(() {
          _isAdminChecked = true;
          _isAdminUser = false;
        });
      }
    }
  }

  // Use cached admin status for operations
  Future<bool> _isAdmin() async {
    if (_isAdminChecked) return _isAdminUser;

    User? currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      return userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>)['role'] == "admin";
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  Future<void> _respondToFeedback(DocumentSnapshot review) async {
    final response = _responseController.text.trim();
    if (response.isEmpty) {
      _showSnackBar('Response cannot be empty', isError: true);
      return;
    }

    // Check if user is authenticated
    if (_auth.currentUser == null) {
      _showSnackBar('You must be logged in to respond', isError: true);
      return;
    }

    // Verify admin status before updating
    bool admin = await _isAdmin();
    if (!admin) {
      _showSnackBar(
        'You do not have permission to respond to reviews',
        isError: true,
      );
      return;
    }

    try {
      // Only update with the adminResponse field - removed the extra fields
      await _firestore.collection('reviews').doc(review.id).update({
        'adminResponse': response,
      });

      _responseController.clear();
      if (mounted) Navigator.of(context).pop();

      _showSnackBar('Response sent successfully', isError: false);
    } catch (e) {
      _showSnackBar('Error sending response: $e', isError: true);
    }
  }

  Future<void> _deleteReview(DocumentSnapshot review) async {
    // Check if user is authenticated
    if (_auth.currentUser == null) {
      _showSnackBar('You must be logged in to delete reviews', isError: true);
      return;
    }

    // Verify admin status before deleting
    bool admin = await _isAdmin();
    if (!admin) {
      _showSnackBar(
        'You do not have permission to delete reviews',
        isError: true,
      );
      return;
    }

    try {
      await _firestore.collection('reviews').doc(review.id).delete();
      _showSnackBar('Review deleted successfully', isError: false);
    } catch (e) {
      _showSnackBar('Error deleting review: $e', isError: true);
    }
  }

  void _showResponseDialog(DocumentSnapshot review) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Respond to Feedback'),
          content: TextField(
            controller: _responseController,
            decoration: InputDecoration(
              hintText: 'Type your official response',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _respondToFeedback(review),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(DocumentSnapshot review) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete this review? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReview(review);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Management'),
        backgroundColor: const Color(0xFF4CAF50),
        leading: const CupertinoNavigationBarBackButton(color: Colors.white),
      ),
      body:
          !_isAdminChecked
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              )
              : !_isAdminUser
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: Colors.red, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'You do not have permission to access this page',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('reviews')
                        .orderBy('date', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4CAF50),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading reviews',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.feedback_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reviews found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var review = snapshot.data!.docs[index];
                      var reviewData =
                          review.data() as Map<String, dynamic>? ?? {};

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            reviewData['name'] ?? 'Anonymous User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (starIndex) => Icon(
                                    starIndex < (reviewData['rating'] ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Text(reviewData['comment'] ?? 'No comment'),
                              Text(
                                'Date: ${_formatDate(reviewData['date'])}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (reviewData['adminResponse'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Admin Response: ${reviewData['adminResponse']}',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Removed check circle icon since resolved status is gone
                              IconButton(
                                icon: const Icon(
                                  Icons.reply,
                                  color: Color(0xFF4CAF50),
                                ),
                                onPressed: () => _showResponseDialog(review),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _showDeleteConfirmation(review),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown Date';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Invalid Date';
    }

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }
}

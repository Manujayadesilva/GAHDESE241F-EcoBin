import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EventsPage(),
      routes: {
        '/signin': (context) => SignInPage(), // You'll need to create this page
      },
    );
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track current filter settings
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Events",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Add user profile icon
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              _manageUserProfile();
            },
          ),
        ],
      ),
      body: _buildEventsTab(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.filter_list),
        onPressed: () {
          _showFilterDialog(context);
        },
      ),
    );
  }

  // Profile management function
  void _manageUserProfile() async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      _showSignInPrompt();
      return;
    }

    // Navigate to profile page or show profile options
    // This could be expanded in the future
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged in as: ${currentUser.email}'),
        action: SnackBarAction(
          label: 'Sign Out',
          onPressed: () async {
            await _auth.signOut();
            setState(() {}); // Refresh UI after sign out
          },
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    // Build query with filters
    Query eventsQuery = _firestore
        .collection('events')
        .orderBy('date', descending: false);

    // Apply date filters if set
    if (_startDate != null) {
      eventsQuery = eventsQuery.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!),
      );
    }

    if (_endDate != null) {
      eventsQuery = eventsQuery.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(_endDate!),
      );
    }

    // Category filters would need to be applied differently as Firestore doesn't support OR queries directly
    // For simplicity, we'll filter categories in the UI if needed

    return StreamBuilder<QuerySnapshot>(
      stream: eventsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No events found'));
        }

        // Apply category filtering in memory if needed
        var eventDocs = snapshot.data!.docs;
        if (_selectedCategories.isNotEmpty) {
          eventDocs =
              eventDocs.where((doc) {
                var eventData = doc.data() as Map<String, dynamic>;
                String category = eventData['category'] ?? '';
                return _selectedCategories.contains(category);
              }).toList();
        }

        if (eventDocs.isEmpty) {
          return const Center(child: Text('No events match your filters'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: eventDocs.length,
          itemBuilder: (context, index) {
            var event = eventDocs[index];
            var eventData = event.data() as Map<String, dynamic>;
            var eventId = event.id;

            // Check if current user is registered for this event
            return FutureBuilder<bool>(
              future: _isUserRegistered(eventId),
              builder: (context, registrationSnapshot) {
                bool isRegistered = registrationSnapshot.data ?? false;

                return Column(
                  children: [
                    _buildEventCard(
                      eventId: eventId,
                      title: eventData['title'] ?? 'Event Title',
                      date: _formatDate(eventData['date']),
                      time: eventData['time'] ?? 'Time Not Specified',
                      location:
                          eventData['location'] ?? 'Location Not Specified',
                      description:
                          eventData['description'] ??
                          'No description available',
                      category: eventData['category'] ?? 'Uncategorized',
                      isRegistered: isRegistered,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // Check if user is registered for a specific event
  Future<bool> _isUserRegistered(String eventId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      var registrations =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: currentUser.uid)
              .where('eventId', isEqualTo: eventId)
              .limit(1)
              .get();

      return registrations.docs.isNotEmpty;
    } catch (e) {
      print('Error checking registration status: $e');
      return false;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>> _getUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return {};

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        // Create a new user document if it doesn't exist
        Map<String, dynamic> newUserData = {
          'email': currentUser.email,
          'name': currentUser.displayName ?? 'Anonymous',
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set(newUserData);
        return newUserData;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  // Register user for event
  Future<void> _registerForEvent(String eventId, String eventTitle) async {
    User? currentUser = _auth.currentUser;

    // If not signed in, show sign-in prompt
    if (currentUser == null) {
      _showSignInPrompt();
      return;
    }

    try {
      // Show loading indicator
      _showLoadingDialog('Registering...');

      // Get user data from Firebase
      Map<String, dynamic> userData = await _getUserData();

      // Create the registrations collection if it doesn't exist
      CollectionReference registrationsRef = _firestore.collection(
        'registrations',
      );

      // Register user for the event with error handling
      try {
        await registrationsRef.add({
          'userId': currentUser.uid,
          'eventId': eventId,
          'eventTitle': eventTitle,
          'registeredAt': FieldValue.serverTimestamp(),
          'userEmail': currentUser.email,
          'userName':
              userData['name'] ?? currentUser.displayName ?? 'Anonymous',
          'userPhone': userData['phone'] ?? '',
        });

        // Update event participation count (optional)
        DocumentReference eventRef = _firestore
            .collection('events')
            .doc(eventId);
        _firestore.runTransaction((transaction) async {
          DocumentSnapshot eventDoc = await transaction.get(eventRef);
          if (eventDoc.exists) {
            int currentCount =
                (eventDoc.data() as Map<String, dynamic>)['participantCount'] ??
                0;
            transaction.update(eventRef, {
              'participantCount': currentCount + 1,
            });
          }
        });

        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for the event!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        setState(() {}); // Refresh UI
      } catch (error) {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        // Show more specific error message
        String errorMessage = 'Registration failed. Please try again.';
        if (error.toString().contains('permission-denied')) {
          errorMessage =
              'Permission denied. Make sure you are logged in with the correct account.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Handle any other errors
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show loading dialog
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
              const SizedBox(width: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // Cancel registration
  Future<void> _cancelRegistration(String eventId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Show loading indicator
      _showLoadingDialog('Cancelling registration...');

      // Find registration document
      var registrations =
          await _firestore
              .collection('registrations')
              .where('userId', isEqualTo: currentUser.uid)
              .where('eventId', isEqualTo: eventId)
              .get();

      // Delete all matching registrations
      for (var doc in registrations.docs) {
        await doc.reference.delete();
      }

      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Update event participation count (optional)
      DocumentReference eventRef = _firestore.collection('events').doc(eventId);
      _firestore.runTransaction((transaction) async {
        DocumentSnapshot eventDoc = await transaction.get(eventRef);
        if (eventDoc.exists) {
          int currentCount =
              (eventDoc.data() as Map<String, dynamic>)['participantCount'] ??
              0;
          if (currentCount > 0) {
            transaction.update(eventRef, {
              'participantCount': currentCount - 1,
            });
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration cancelled'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel registration: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show sign in prompt with improved styling
  void _showSignInPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.all(16),
          title: const Text(
            'Sign In Required',
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You need to sign in before registering for an event.',
            style: TextStyle(color: Colors.grey[800]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // First close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInPage(),
                  ), // Navigate to your existing SignInPage
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventCard({
    required String eventId,
    required String title,
    required String date,
    required String time,
    required String location,
    required String description,
    required bool isRegistered,
    String category = 'Uncategorized',
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_outlined,
                    size: 28,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Display category
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4CAF50),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isRegistered)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Color(0xFF4CAF50),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Registered",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(),
                    ElevatedButton(
                      onPressed: () {
                        if (isRegistered) {
                          _cancelRegistration(eventId);
                        } else {
                          _registerForEvent(eventId, title);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isRegistered
                                ? Colors.grey[200]
                                : const Color(0xFF4CAF50),
                        foregroundColor:
                            isRegistered ? Colors.grey[700] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(isRegistered ? "Cancel" : "Register"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Temporary state for the dialog
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;
    List<String> tempSelectedCategories = List.from(_selectedCategories);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text(
                  "Filter Events",
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date Range",
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: tempStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF4CAF50),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  tempStartDate = picked;
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              tempStartDate == null
                                  ? "Start Date"
                                  : "${tempStartDate!.day}/${tempStartDate!.month}/${tempStartDate!.year}",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: tempEndDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF4CAF50),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  tempEndDate = picked;
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              tempEndDate == null
                                  ? "End Date"
                                  : "${tempEndDate!.day}/${tempEndDate!.month}/${tempEndDate!.year}",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Categories",
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChipInDialog(
                          "Cleanup",
                          tempSelectedCategories,
                          (selected) {
                            setState(() {
                              _toggleCategory(
                                tempSelectedCategories,
                                "Cleanup",
                              );
                            });
                          },
                        ),
                        _buildFilterChipInDialog(
                          "Education",
                          tempSelectedCategories,
                          (selected) {
                            setState(() {
                              _toggleCategory(
                                tempSelectedCategories,
                                "Education",
                              );
                            });
                          },
                        ),
                        _buildFilterChipInDialog(
                          "Workshop",
                          tempSelectedCategories,
                          (selected) {
                            setState(() {
                              _toggleCategory(
                                tempSelectedCategories,
                                "Workshop",
                              );
                            });
                          },
                        ),
                        _buildFilterChipInDialog(
                          "Community",
                          tempSelectedCategories,
                          (selected) {
                            setState(() {
                              _toggleCategory(
                                tempSelectedCategories,
                                "Community",
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        tempStartDate = null;
                        tempEndDate = null;
                        tempSelectedCategories = [];
                      });
                    },
                    child: const Text(
                      "Reset",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Apply filters and close dialog
                      this.setState(() {
                        _startDate = tempStartDate;
                        _endDate = tempEndDate;
                        _selectedCategories = tempSelectedCategories;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Apply"),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _toggleCategory(List<String> categories, String category) {
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedCategories.contains(label);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _toggleCategory(_selectedCategories, label);
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFFE8F5E9),
      checkmarkColor: const Color(0xFF4CAF50),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[800],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildFilterChipInDialog(
    String label,
    List<String> selectedCategories,
    Function(bool) onSelected,
  ) {
    bool isSelected = selectedCategories.contains(label);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFFE8F5E9),
      checkmarkColor: const Color(0xFF4CAF50),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[800],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Date Not Specified';

    DateTime dateTime;
    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'Invalid Date';
    }

    return '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/binlocation.dart';

import 'binreview.dart';
import 'eventsnupdates.dart';
import 'profile.dart';
import 'request_bins.dart';
import 'signin_page.dart' as signin;
import 'signup_page.dart' as signup;

class EcoBinDashboard extends StatefulWidget {
  const EcoBinDashboard({super.key});

  @override
  State<EcoBinDashboard> createState() => _EcoBinDashboardState();
}

class _EcoBinDashboardState extends State<EcoBinDashboard> {
  User? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 0;

  // ScrollController to manage scrolling and ensure proper padding
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    _currentUser = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for more accurate padding calculations
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Adjust the height for the bottom navigation bar and floating action button
    final navigationBarHeight = kBottomNavigationBarHeight + bottomPadding;

    // Calculate safer padding to prevent overflow - adjusted to be more conservative
    final safePadding = navigationBarHeight + 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 12),
            const Text(
              "EcoBin",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF757575),
                  size: 26,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              )
              : SafeArea(
                // Use SafeArea with bottom set to false to manage bottom padding manually
                bottom: false,
                child: Padding(
                  // Add padding to all sides except bottom which is handled by ListView padding
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: ListView(
                    controller: _scrollController,
                    // Add bottom padding to prevent content from being hidden behind navigation
                    padding: EdgeInsets.only(bottom: safePadding),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser != null
                                  ? "Welcome, ${_currentUser!.displayName ?? 'User'}"
                                  : "Welcome to EcoBin",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Make a difference with smart waste management",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_currentUser == null)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAuthButton(
                                      title: "Sign In",
                                      isPrimary: true,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const signin.SignInPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildAuthButton(
                                      title: "Sign Up",
                                      isPrimary: false,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const signup.SignUpPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (_currentUser != null) ...[
                        const SizedBox(height: 24),
                        _buildUserProfileCard(),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "View All",
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Modified GridView with optimized childAspectRatio and reduced content
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12, // Reduced spacing
                        crossAxisSpacing: 12, // Reduced spacing
                        childAspectRatio:
                            1.4, // Increased to make cards shorter
                        children: [
                          _buildServiceCard(
                            icon: Icons.location_on_outlined,
                            title: "Find Bins",
                            description: "Locate recycle bins near you",
                            color: const Color(0xFFE8F5E9),
                            iconColor: const Color(0xFF388E3C),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GoogleMapScreen(),
                                ),
                              );
                            },
                          ),
                          _buildServiceCard(
                            icon: Icons.history_outlined,
                            title: "View History",
                            description: "Your recycling activities",
                            color: const Color(0xFFE1F5FE),
                            iconColor: const Color(0xFF0288D1),
                            onPressed: () {
                              if (_currentUser != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileOfUser(),
                                  ),
                                );
                              } else {
                                _showLoginRequiredDialog();
                              }
                            },
                          ),
                          _buildServiceCard(
                            icon: Icons.add_circle_outline,
                            title: "Bin Request",
                            description: "Request a new bin",
                            color: const Color(0xFFFFF3E0),
                            iconColor: const Color(0xFFFF9800),
                            onPressed: () {
                              if (_currentUser != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const BinRequestPage(),
                                  ),
                                );
                              } else {
                                _showLoginRequiredDialog();
                              }
                            },
                          ),
                          _buildServiceCard(
                            icon: Icons.star_outline,
                            title: "Rate & Reviews",
                            description: "Share your experience",
                            color: const Color(0xFFF3E5F5),
                            iconColor: const Color(0xFF9C27B0),
                            onPressed: () {
                              if (_currentUser != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BinReviewPage(),
                                  ),
                                );
                              } else {
                                _showLoginRequiredDialog();
                              }
                            },
                          ),
                          _buildServiceCard(
                            icon: Icons.event_available_outlined,
                            title: "Events & Updates",
                            description: "Stay informed",
                            color: const Color(0xFFE0F2F1),
                            iconColor: const Color(0xFF00897B),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EventsPage(),
                                ),
                              );
                            },
                          ),
                          _buildServiceCard(
                            icon: Icons.eco_outlined,
                            title: "Eco Tips",
                            description: "Learn to be eco-friendly",
                            color: const Color(0xFFF1F8E9),
                            iconColor: const Color(0xFF8BC34A),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildRecentActivitySection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: const Color(0xFF9E9E9E),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: "Events",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              break; // Already on home
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventsPage()),
              );
              break;
            case 2:
              // Stats page - would need to be implemented
              break;
            case 3:
              if (_currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileOfUser()),
                );
              } else {
                _showLoginRequiredDialog();
              }
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick find bins action
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GoogleMapScreen()),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.search, color: Colors.white),
      ),
      // Keep this set to false to avoid resizeToAvoidBottomInset issues
      resizeToAvoidBottomInset: false,
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Login Required",
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "You need to be logged in to access this feature. Would you like to sign in now?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const signin.SignInPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Sign In",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFE8F5E9),
                backgroundImage:
                    _currentUser?.photoURL != null
                        ? NetworkImage(_currentUser!.photoURL!)
                        : null,
                child:
                    _currentUser?.photoURL == null
                        ? const Icon(
                          Icons.person,
                          size: 30,
                          color: Color(0xFF4CAF50),
                        )
                        : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser?.displayName ?? "EcoBin User",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?.email ?? "",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Eco Enthusiast",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _signOut,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4CAF50)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(
                Icons.logout,
                size: 18,
                color: Color(0xFF4CAF50),
              ),
              label: const Text(
                "Sign Out",
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required String title,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.transparent,
        foregroundColor: isPrimary ? const Color(0xFF2E7D32) : Colors.white,
        elevation: isPrimary ? 0 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withOpacity(isPrimary ? 1 : 0.3),
            width: 1,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isPrimary ? const Color(0xFF2E7D32) : Colors.white,
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced padding
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ), // Slightly smaller icon
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15, // Slightly smaller font
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 2), // Reduced spacing
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ), // Slightly smaller font
                maxLines: 1, // Limit to one line
                overflow:
                    TextOverflow.ellipsis, // Add ellipsis if text overflows
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        if (_currentUser == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Image.network(
                  "https://picsum.photos/200",
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Sign in to view your recent activities",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Track your waste management journey and earn eco-points",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const signin.SignInPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              _buildActivityItem(
                icon: Icons.recycling,
                title: "Plastic Recycled",
                subtitle: "You recycled 2.5kg of plastic",
                time: "Yesterday",
                iconColor: const Color(0xFF2196F3),
                iconBgColor: const Color(0xFFE3F2FD),
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                icon: Icons.location_on,
                title: "New Bin Found",
                subtitle: "You discovered a new recycling point",
                time: "2 days ago",
                iconColor: const Color(0xFF4CAF50),
                iconBgColor: const Color(0xFFE8F5E9),
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                icon: Icons.star,
                title: "Rating Submitted",
                subtitle: "You rated a bin location with 5 stars",
                time: "1 week ago",
                iconColor: const Color(0xFFFF9800),
                iconBgColor: const Color(0xFFFFF3E0),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

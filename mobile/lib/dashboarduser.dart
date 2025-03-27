import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'binlocation.dart';
import 'binreview.dart';
import 'eventsnupdates.dart';
import 'profile.dart';
import 'request_bins.dart';
import 'signin_page.dart';
import 'signup_page.dart';
// Import your other pages here
// import 'find_bins_page.dart';
// import 'view_history_page.dart';
// import 'bin_types_page.dart';
// import 'payment_page.dart';
// import 'nearby_bins_page.dart';
// import 'green_points_page.dart';
// import 'eco_tips_page.dart';
// import 'notifications_page.dart';
// import 'profile_page.dart';
// import 'eco_updates_page.dart';
// import 'news_detail_page.dart';

class EcoBinDashboard extends StatefulWidget {
  const EcoBinDashboard({Key? key}) : super(key: key);

  @override
  State<EcoBinDashboard> createState() => _EcoBinDashboardState();
}

class _EcoBinDashboardState extends State<EcoBinDashboard> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    // Set up auth state listener
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  // Check if user is already logged in
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.eco, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            const Text(
              "EcoBin",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {
              // Uncomment when you have the NotificationsPage ready
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const NotificationsPage(),
              //   ),
              // );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section with dynamic greeting based on auth state
                    Text(
                      _currentUser != null
                          ? "Welcome, ${_currentUser!.displayName ?? 'User'}"
                          : "Welcome to EcoBin",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Smart waste management",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Auth cards - Only show if not logged in
                    if (_currentUser == null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildAuthCard(
                              title: "Sign In",
                              isPrimary: true,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAuthCard(
                              title: "Sign Up",
                              isPrimary: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      // Show profile overview and sign out option when logged in
                      _buildUserProfileCard(),
                      const SizedBox(height: 24),
                    ],

                    // Quick actions
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick actions grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildServiceCard(
                          icon: Icons.location_on_outlined,
                          title: "Find Bins",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BinLocation(),
                              ),
                            );
                          },
                        ),
                        _buildServiceCard(
                          icon: Icons.history_outlined,
                          title: "View History",
                          onPressed: () {
                            // Uncomment when you have the ViewHistoryPage ready
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const ViewHistoryPage(),
                            //   ),
                            // );
                          },
                        ),
                        _buildServiceCard(
                          icon: Icons.category_outlined,
                          title: "Bin Request",
                          onPressed: () {
                            // Check if user is logged in before navigating
                            if (_currentUser != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BinRequestPage(),
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
                          onPressed: () {
                            // Check if user is logged in before navigating
                            if (_currentUser != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BinReviewPage(),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const EventsAndUpdatesPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Featured section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Featured",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Uncomment when you have the AllFeaturedPage ready
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const AllFeaturedPage(),
                            //   ),
                            // );
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "See All",
                            style: TextStyle(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Featured cards
                    _buildFeaturedCard(
                      title: "Find Nearby Bins",
                      description: "Locate recycling points near you",
                      icon: Icons.location_on_outlined,
                      onPressed: () {
                        // Uncomment when you have the NearbyBinsPage ready
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const NearbyBinsPage(),
                        //   ),
                        // );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFeaturedCard(
                      title: "Earn Green Points",
                      description: "Get rewards for recycling",
                      icon: Icons.monetization_on_outlined,
                      onPressed: () {
                        // Check if user is logged in for features requiring authentication
                        if (_currentUser != null) {
                          // Uncomment when you have the GreenPointsPage ready
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const GreenPointsPage(),
                          //   ),
                          // );
                        } else {
                          _showLoginRequiredDialog();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFeaturedCard(
                      title: "Eco Tips & Updates",
                      description: "Learn how to protect our environment",
                      icon: Icons.eco_outlined,
                      onPressed: () {
                        // Uncomment when you have the EcoTipsPage ready
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const EcoTipsPage(),
                        //   ),
                        // );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Environmental updates section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Eco Updates",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Uncomment when you have the AllEcoUpdatesPage ready
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const AllEcoUpdatesPage(),
                            //   ),
                            // );
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "See All",
                            style: TextStyle(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildEcoUpdateCard(
                      title: "Reduce Plastic Waste",
                      description:
                          "Simple steps to minimize plastic in your daily life",
                      date: "Mar 15, 2025",
                      onLearnMorePressed: () {
                        // Uncomment when you have the specific update page ready
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const EcoUpdateDetailPage(
                        //       title: "Reduce Plastic Waste",
                        //       date: "Mar 15, 2025",
                        //       // Pass other required parameters
                        //     ),
                        //   ),
                        // );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildEcoUpdateCard(
                      title: "Community Cleanup Day",
                      description:
                          "Join us this weekend to clean local waterways",
                      date: "Mar 22, 2025",
                      onLearnMorePressed: () {
                        // Uncomment when you have the specific update page ready
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const EcoUpdateDetailPage(
                        //       title: "Community Cleanup Day",
                        //       date: "Mar 22, 2025",
                        //       // Pass other required parameters
                        //     ),
                        //   ),
                        // );
                      },
                    ),

                    const SizedBox(height: 32),

                    // News section
                    const Text(
                      "News",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildNewsCard(
                      onLearnMorePressed: () {
                        // Uncomment when you have the NewsDetailPage ready
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const NewsDetailPage(
                        //       title: "New Recycling Center",
                        //       // Pass other required parameters
                        //     ),
                        //   ),
                        // );
                      },
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
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
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation bar item clicks
          switch (index) {
            case 0:
              // Already on home page
              break;
            case 1:
              // Navigate to Events page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventsAndUpdatesPage(),
                ),
              );
              break;
            case 2:
              // Navigate to Alerts page
              // Uncomment when you have the AlertsPage ready
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const AlertsPage(),
              //   ),
              // );
              break;
            case 3:
              // Navigate to Profile page
              if (_currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileOfUser(children: []),
                  ),
                );
              } else {
                _showLoginRequiredDialog();
              }
              break;
          }
        },
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Required"),
          content: const Text(
            "You need to be logged in to access this feature. Would you like to sign in now?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              child: const Text(
                "Sign In",
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser?.displayName ?? "EcoBin User",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?.email ?? "",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _signOut,
              icon: const Icon(
                Icons.logout,
                size: 18,
                color: Color(0xFF4CAF50),
              ),
              label: const Text(
                "Sign Out",
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard({
    required String title,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isPrimary ? Colors.transparent : const Color(0xFF4CAF50),
          width: 1,
        ),
      ),
      color: isPrimary ? const Color(0xFF4CAF50) : Colors.white,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isPrimary ? Colors.white : const Color(0xFF4CAF50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24, color: const Color(0xFF4CAF50)),
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
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEcoUpdateCard({
    required String title,
    required String description,
    required String date,
    required VoidCallback onLearnMorePressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onLearnMorePressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.eco_outlined,
                      size: 20,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: onLearnMorePressed,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Learn More",
                      style: TextStyle(
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
      ),
    );
  }

  Widget _buildNewsCard({required VoidCallback onLearnMorePressed}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.nature_outlined,
                size: 40,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "New Recycling Center",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Join us for the grand opening of our new recycling center this weekend!",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onLearnMorePressed,
                    child: const Text(
                      "Learn More",
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

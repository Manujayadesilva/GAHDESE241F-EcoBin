import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Events_admin.dart';
import 'admin_profile.dart';
import 'binStatus_admin.dart';
import 'dashboarduser.dart';
import 'feedback_look.dart';
import 'user_manage.dart';
import 'binlocation.dart';
import 'bin_history.dart';
import 'signin_page.dart' as signin;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  User? _currentAdmin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentAdmin = user;
      });
    });
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    _currentAdmin = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const signin.SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: CupertinoNavigationBarBackButton(
          color: const Color(0xFF4CAF50),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const EcoBinDashboard()),
              (Route<dynamic> route) => false,
            );
          },
        ),

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "EcoBin Dashboard",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: const Color.fromARGB(0, 215, 21, 21),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: _signOut,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFF757575),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              )
              : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildWelcomeHeader(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Management Tools"),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.35,
                      children: [
                        _buildServiceCard(
                          icon: Icons.people_outline,
                          title: "User Management",
                          description: "Manage system users",
                          iconColor: const Color(0xFF1976D2),
                          onPressed: () => _navigateTo(UserManagementPage()),
                        ),
                        _buildServiceCard(
                          icon: Icons.delete_outline,
                          title: "Bin Status",
                          description: "Monitor bin conditions",
                          iconColor: const Color(0xFFFF7043),
                          onPressed: () => _navigateTo(BinStatusPage()),
                        ),
                        _buildServiceCard(
                          icon: Icons.location_on_outlined,
                          title: "Bin Locations",
                          description: "View bin placements",
                          iconColor: const Color(0xFF7CB342),
                          onPressed: () => _navigateTo(GoogleMapScreen()),
                        ),
                        _buildServiceCard(
                          icon: Icons.history_outlined,
                          title: "Bin History",
                          description: "Track bin data over time",
                          iconColor: const Color(0xFF5C6BC0),
                          onPressed: () => _navigateTo(BinHistoryPage()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Additional Controls"),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.35,
                      children: [
                        _buildServiceCard(
                          icon: Icons.event_available_outlined,
                          title: "Event Management",
                          description: "Organize community events",
                          iconColor: const Color(0xFF26A69A),
                          onPressed: () => _navigateTo(EventManagementPage()),
                        ),
                        _buildServiceCard(
                          icon: Icons.feedback_outlined,
                          title: "Feedback",
                          description: "Review user feedback",
                          iconColor: const Color(0xFFFFB300),
                          onPressed:
                              () => _navigateTo(FeedbackManagementPage()),
                        ),
                        _buildServiceCard(
                          icon: Icons.person_outline,
                          title: "Admin Profile",
                          description: "Manage your account",
                          iconColor: const Color(0xFF8E24AA),
                          onPressed: () => _navigateTo(AdminProfileApp()),
                        ),
                        _buildServiceCard(
                          icon: Icons.analytics_outlined,
                          title: "Analytics",
                          description: "View system metrics",
                          iconColor: const Color(0xFF00897B),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Analytics feature coming soon"),
                                backgroundColor: Color(0xFF4CAF50),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Welcome, ${_currentAdmin?.displayName ?? 'Admin'}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.eco, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Manage waste disposal efficiently and sustainably",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  "EcoBin Management Console",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

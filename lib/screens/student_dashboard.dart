import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:placement_portal_app/screens/application_screen.dart';
import 'package:placement_portal_app/screens/job_screen.dart';
import 'package:placement_portal_app/screens/notifications_screen.dart';
import 'package:placement_portal_app/screens/profile_screen.dart';
import 'job_details_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int currentIndex = 0;

  /// MODERN STAT CARD (Glassmorphism on Gradient)
  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // Semi-transparent overlay
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// MODERN QUICK ACTION CARD
  Widget _buildQuickAction(IconData icon, String title, Color color, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16), // Squircle
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155), // Slate 700
              ),
            )
          ],
        ),
      ),
    );
  }

  /// MODERN JOB CARD (Reused from job_screen for consistency)
  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job, String jobId) {
    final company = job['company'] ?? 'Unknown';
    final role = job['title'] ?? 'Role';
    final salary = job['salary'] ?? 'N/A';
    final location = job['location'] ?? 'Location';

    // Generate a pseudo-random color for the company logo background based on name
    final colors = [
      const Color(0xFFEF4444), // Red 500
      const Color(0xFF3B82F6), // Blue 500
      const Color(0xFF10B981), // Emerald 500
      const Color(0xFFF59E0B), // Amber 500
      const Color(0xFF8B5CF6), // Purple 500
    ];
    final colorBg = colors[company.length % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorBg.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12), // Squircle
                ),
                child: Center(
                  child: Text(
                    company[0].toUpperCase(),
                    style: TextStyle(
                      color: colorBg,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF0F172A), // Slate 900
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: const TextStyle(
                        color: Color(0xFF64748B), // Slate 500
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              const Icon(Icons.bookmark_border_rounded, color: Color(0xFFCBD5E1)), // Slate 300
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag(Icons.payments_outlined, salary, const Color(0xFF10B981), const Color(0xFFECFDF5)), // Emerald
              const SizedBox(width: 8),
              _buildTag(Icons.location_on_outlined, location, const Color(0xFF6366F1), const Color(0xFFEEF2FF)), // Indigo
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(job: job, jobId: jobId),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFF0F172A), // Slate 900
              ),
              child: const Text(
                "View Details",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String text, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? "Student";

    return SingleChildScrollView(
      child: Column(
        children: [
          /// HERO HEADER
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24,
              right: 24,
              bottom: 32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6366F1), // Indigo 500
                  Color(0xFF4F46E5), // Indigo 600
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back 👋",
                          style: TextStyle(
                            color: Colors.indigo.shade100,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    
                    // Notification Bell
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                            onPressed: () {
                              setState(() { currentIndex = 3; });
                            },
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B), // Amber 500
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// STATS GRID
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('applications')
                      .where('studentUid', isEqualTo: uid)
                      .snapshots(),
                  builder: (ctx, appSnap) {
                    final apps = appSnap.data?.docs ?? [];
                    final totalApps = apps.length;
                    final shortlisted = apps.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == 'Shortlisted';
                    }).length;
                    final interviews = apps.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == 'Interview';
                    }).length;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('jobs')
                          .where('status', isEqualTo: 'Active')
                          .snapshots(),
                      builder: (ctx, jobSnap) {
                        final activeJobs = jobSnap.data?.docs.length ?? 0;

                        return GridView.count(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard("Applications", "$totalApps", Icons.description_outlined),
                            _buildStatCard("Shortlisted", "$shortlisted", Icons.check_circle_outline),
                            _buildStatCard("Interviews", "$interviews", Icons.calendar_today_outlined),
                            _buildStatCard("Jobs Available", "$activeJobs", Icons.work_outline),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// QUICK ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A), // Slate 900
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildQuickAction(
                      Icons.work_outline_rounded,
                      "Browse Jobs",
                      const Color(0xFF3B82F6), // Blue 500
                      const Color(0xFFEFF6FF), // Blue 50
                      () => setState(() { currentIndex = 1; }),
                    ),
                    _buildQuickAction(
                      Icons.description_outlined,
                      "My Applications",
                      const Color(0xFF8B5CF6), // Purple 500
                      const Color(0xFFF5F3FF), // Purple 50
                      () => setState(() { currentIndex = 2; }),
                    ),
                    _buildQuickAction(
                      Icons.person_outline_rounded,
                      "My Profile",
                      const Color(0xFF10B981), // Emerald 500
                      const Color(0xFFECFDF5), // Emerald 50
                      () => setState(() { currentIndex = 4; }),
                    ),
                    _buildQuickAction(
                      Icons.notifications_outlined,
                      "Notifications",
                      const Color(0xFFF59E0B), // Amber 500
                      const Color(0xFFFEF3C7), // Amber 50
                      () => setState(() { currentIndex = 3; }),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Latest Postings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A), // Slate 900
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() { currentIndex = 1; }),
                      child: const Text(
                        "See All",
                        style: TextStyle(
                          color: Color(0xFF4F46E5), // Indigo 600
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 8),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('jobs')
                      .where('status', isEqualTo: 'Active')
                      .snapshots(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                        )
                      );
                    }
                    if (snap.hasError) {
                      return const Center(child: Text("Error fetching jobs"));
                    }

                    final docsResponse = snap.data?.docs ?? [];
                    if (docsResponse.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: Center(
                          child: Text(
                            "No active jobs at the moment",
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ),
                      );
                    }

                    // Sort locally
                    final docs = docsResponse.toList();
                    docs.sort((a, b) {
                      final dataA = a.data() as Map<String, dynamic>;
                      final dataB = b.data() as Map<String, dynamic>;
                      final tsA = dataA['createdAt'] as Timestamp?;
                      final tsB = dataB['createdAt'] as Timestamp?;
                      if (tsA == null || tsB == null) return 0;
                      return tsB.compareTo(tsA);
                    });

                    // Take latest 3
                    final latestDocs = docs.take(3).toList();

                    return Column(
                      children: latestDocs.map((doc) {
                        final job = doc.data() as Map<String, dynamic>;
                        return _buildJobCard(context, job, doc.id);
                      }).toList(),
                    );
                  },
                ),
                    
                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50

      /// BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4F46E5), // Indigo 600
          unselectedItemColor: const Color(0xFF94A3B8), // Slate 400
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.work_rounded), label: "Jobs"),
            BottomNavigationBarItem(icon: Icon(Icons.description_rounded), label: "Applied"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: "Alerts"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
          ],
        ),
      ),

      body: IndexedStack(
        index: currentIndex,
        children: [
          _buildHomeContent(),
          const JobsScreen(),
          const ApplicationsScreen(),
          const NotificationsScreen(),
          const ProfileScreen(),
        ],
      ),
    );
  }
}

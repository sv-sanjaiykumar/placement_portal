// ============================================================
// admin_dashboard.dart
// Dashboard screen for Administrators.
// Shows system statistics, user management overview,
// and placement activity analytics.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'create_student_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  // ── Color Palette (Teal / Emerald theme for Admin) ─────────
  static const Color _primary = Color(0xFF0D9488);    // Teal 600
  static const Color _primaryLight = Color(0xFFF0FDFA); // Teal 50
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate700 = Color(0xFF334155);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate200 = Color(0xFFE2E8F0);
  static const Color _slate100 = Color(0xFFF1F5F9);
  static const Color _slate50 = Color(0xFFF8FAFC);

  // ── Sign Out Handler ────────────────────────────────────────
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Navigate back to Login and clear the navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ── Stat Card Widget ────────────────────────────────────────
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          // Big number
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _slate900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: _slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Activity Row ─────────────────────────────────────
  Widget _buildActivityRow(
    String actor,
    String action,
    String time,
    Color dotColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Colored dot
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: _slate700),
                    children: [
                      TextSpan(
                        text: '$actor ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: action),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: _slate500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── User Management Card ────────────────────────────────────
  Widget _buildUserCard(String name, String email, String role, Color roleColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circle
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withOpacity(0.12),
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(fontSize: 12, color: _slate500),
                ),
              ],
            ),
          ),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: roleColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Home Tab Content ────────────────────────────────────────
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── GRADIENT HEADER ─────────────────────────────────
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
                colors: [Color(0xFF0F9B8E), Color(0xFF0D9488)],
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
                          'Admin Control Panel 🛡️',
                          style: TextStyle(
                            color: Colors.teal.shade100,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PlacementHub Admin',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    // Sign out button
                    GestureDetector(
                      onTap: _signOut,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── STATS GRID (2×2) ─────────────────────────
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.0,
                  children: [
                    _buildGlassStatCard('Total Users', '248', Icons.people_rounded),
                    _buildGlassStatCard('Active Jobs', '34', Icons.work_rounded),
                    _buildGlassStatCard('Placed', '89', Icons.check_circle_rounded),
                    _buildGlassStatCard('Pending', '12', Icons.hourglass_top_rounded),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── STATS CARDS ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Platform Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _slate900,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildStatCard('Students', '198', Icons.school_rounded,
                        const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
                    _buildStatCard('Companies', '23', Icons.business_rounded,
                        const Color(0xFF9333EA), const Color(0xFFFAF5FF)),
                    _buildStatCard('Applications', '512', Icons.description_rounded,
                        const Color(0xFF0D9488), const Color(0xFFF0FDFA)),
                    _buildStatCard('Offers Made', '89', Icons.handshake_rounded,
                        const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
                  ],
                ),

                const SizedBox(height: 28),

                // ── RECENT ACTIVITY ──────────────────────────
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _slate900,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _slate100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildActivityRow('Google', 'posted a new SDE role', '2 min ago', const Color(0xFF4F46E5)),
                      Divider(color: _slate200, height: 1),
                      _buildActivityRow('Rahul Sharma', 'applied to Microsoft SDE', '15 min ago', const Color(0xFF10B981)),
                      Divider(color: _slate200, height: 1),
                      _buildActivityRow('TCS', 'updated salary bracket', '1 hour ago', const Color(0xFFF59E0B)),
                      Divider(color: _slate200, height: 1),
                      _buildActivityRow('Priya M.', 'completed profile setup', '3 hours ago', const Color(0xFF8B5CF6)),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigate to Create Student Screen ────────────────────
  void _openCreateStudent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateStudentScreen()),
    );
  }

  // ── Users Tab ─────────────────────────────────────────────
  Widget _buildUsersContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 24,
        right: 24,
        bottom: 100, // extra bottom padding for FAB
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row with Create button ──────────────────
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Users',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _slate900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View and manage all registered users',
                      style: TextStyle(color: _slate500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // ── Quick-add button ────────────────────────────
              ElevatedButton.icon(
                onPressed: _openCreateStudent,
                icon: const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'Add Student',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Section label ───────────────────────────────────
          _buildSectionLabel('Students', Icons.school_rounded, const Color(0xFF4F46E5)),
          const SizedBox(height: 10),
          _buildUserCard('Sanjay Kumar', 'sanjaiy@gmail.com', 'Student', const Color(0xFF4F46E5)),
          _buildUserCard('Rahul Sharma', 'rahul@example.com', 'Student', const Color(0xFF4F46E5)),
          _buildUserCard('Priya Menon', 'priya@example.com', 'Student', const Color(0xFF4F46E5)),

          const SizedBox(height: 20),
          _buildSectionLabel('Placement Cell & Admin', Icons.admin_panel_settings_outlined, _primary),
          const SizedBox(height: 10),
          _buildUserCard('Placement Cell', 'company@gmail.com', 'Placement Cell', const Color(0xFF9333EA)),
          _buildUserCard('Admin User', 'admin@gmail.com', 'Admin', _primary),
        ],
      ),
    );
  }

  // ── Settings Tab ────────────────────────────────────────────
  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _slate900),
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(Icons.notifications_outlined, 'Notifications', 'Manage alert preferences'),
          _buildSettingsTile(Icons.security_outlined, 'Security', 'Password and 2FA settings'),
          _buildSettingsTile(Icons.tune_outlined, 'Portal Config', 'Configure placement rules'),
          _buildSettingsTile(Icons.bar_chart_outlined, 'Analytics', 'Placement statistics'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label helper ────────────────────────────────────
  Widget _buildSectionLabel(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 7),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _slate100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: _slate900)),
        subtitle: Text(subtitle, style: const TextStyle(color: _slate500, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right_rounded, color: _slate500),
      ),
    );
  }

  // ── Glassmorphism stat card for header ──────────────────────
  Widget _buildGlassStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.85), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,

      // ── FAB: only shows on the Users tab (index 1) ──────────
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _openCreateStudent,
              backgroundColor: _primary,
              elevation: 4,
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              label: const Text(
                'Create Student',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,

      // ── BOTTOM NAV ─────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: _primary,
          unselectedItemColor: _slate500,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          ],
        ),
      ),

      // ── BODY ────────────────────────────────────────────────
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          _buildUsersContent(),
          _buildSettingsContent(),
        ],
      ),
    );
  }
}

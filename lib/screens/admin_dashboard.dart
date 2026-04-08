import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:placement_portal_app/screens/create_student_screen.dart';
import 'package:placement_portal_app/screens/login_screen.dart';
import 'admin/admin_utils.dart';
import 'admin/dashboard_tab.dart';
import 'admin/users_tab.dart';
import 'admin/settings_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _openCreateStudent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateStudentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.slate50,

      // ── FAB: only shows on the Users tab (index 1) ──────────
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _openCreateStudent,
              backgroundColor: AdminTheme.primary,
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
          selectedItemColor: AdminTheme.primary,
          unselectedItemColor: AdminTheme.slate500,
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
          DashboardTab(onSignOut: _signOut),
          const UsersTab(),
          SettingsTab(onSignOut: _signOut),
        ],
      ),
    );
  }
}

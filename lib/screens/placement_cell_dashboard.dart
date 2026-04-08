import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

import 'placement_cell/dashboard_tab.dart';
import 'placement_cell/applicants_tab.dart';
import 'placement_cell/schedule_tab.dart';
import 'placement_cell/placement_utils.dart'; 

class PlacementCellDashboard extends StatefulWidget {
  const PlacementCellDashboard({super.key});

  @override
  State<PlacementCellDashboard> createState() =>
      _PlacementCellDashboardState();
}

class _PlacementCellDashboardState extends State<PlacementCellDashboard> {
  int _currentIndex = 0;
  String? _selectedJobIdFilter;

  // ── Sign out ──────────────────────────────────────────────
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  void _goToApplicants(String jobId) {
    setState(() {
      _selectedJobIdFilter = jobId;
      _currentIndex = 1;
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedJobIdFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlacementTheme.slate50,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: PlacementTheme.primary,
          unselectedItemColor: PlacementTheme.slate500,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          onTap: (i) {
            setState(() {
              _currentIndex = i;
              if (i != 1) {
                // Clear filter when leaving applicants tab
                _selectedJobIdFilter = null;
              }
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded), label: 'Applicants'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded),
                label: 'Schedule'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardTab(
            onViewApplicants: _goToApplicants,
            onSignOut: _signOut,
          ),
          ApplicantsTab(
            jobIdFilter: _selectedJobIdFilter,
            onClearFilter: _clearFilter,
          ),
          ScheduleTab(ctx: context),
        ],
      ),
    );
  }
}

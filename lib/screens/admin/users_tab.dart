import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_utils.dart';
import 'admin_widgets.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  void _openCreateStaff(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Staff creation functionality is coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminTheme.slate900,
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AdminTheme.primary));
        }

        List<Widget> studentWidgets = [];
        List<Widget> staffWidgets = [];

        // Add hardcoded users purely for display fallback
        studentWidgets.add(const AdminUserCard(name: 'Sanjay Kumar (Demo)', email: 'sanjaiy@gmail.com', role: 'Student', roleColor: Color(0xFF4F46E5)));
        staffWidgets.add(const AdminUserCard(name: 'Placement Cell (Demo)', email: 'company@gmail.com', role: 'Placement Cell', roleColor: Color(0xFF9333EA)));
        staffWidgets.add(const AdminUserCard(name: 'Admin User (Demo)', email: 'admin@gmail.com', role: 'Admin', roleColor: AdminTheme.primary));

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Unknown User';
          final email = data['email'] ?? 'No email';
          final role = data['role'] ?? 'unknown';

          if (role == 'student') {
            studentWidgets.add(AdminUserCard(name: name, email: email, role: 'Student', roleColor: const Color(0xFF4F46E5)));
          } else if (role == 'placementCell') {
            staffWidgets.add(AdminUserCard(name: name, email: email, role: 'Placement Cell', roleColor: const Color(0xFF9333EA)));
          } else if (role == 'admin') {
            staffWidgets.add(AdminUserCard(name: name, email: email, role: 'Admin', roleColor: AdminTheme.primary));
          }
        }

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
                            color: AdminTheme.slate900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'View and manage all registered users',
                          style: TextStyle(color: AdminTheme.slate500, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // ── Quick-add staff button ──────────────────────
                  ElevatedButton.icon(
                    onPressed: () => _openCreateStaff(context),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 16, color: Colors.white),
                    label: const Text(
                      'Add Staff',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9333EA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Section label ───────────────────────────────────
              if (studentWidgets.isNotEmpty) ...[
                _buildSectionLabel('Students', Icons.school_rounded, const Color(0xFF4F46E5)),
                const SizedBox(height: 10),
                ...studentWidgets,
                const SizedBox(height: 20),
              ],

              if (staffWidgets.isNotEmpty) ...[
                _buildSectionLabel('Placement Cell & Admin', Icons.admin_panel_settings_outlined, AdminTheme.primary),
                const SizedBox(height: 10),
                ...staffWidgets,
              ],
            ],
          ),
        );
      },
    );
  }
}

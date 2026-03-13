import 'package:flutter/material.dart';
import 'package:placement_portal_app/screens/student_dashboard.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  /// Modern Role Card Widget
  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          highlightColor: bgColor.withOpacity(0.3),
          splashColor: bgColor.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                
                /// ICON CONTAINER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16), // Squircle
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),

                const SizedBox(width: 20),

                /// TEXT AREA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A), // Slate 900
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF64748B), // Slate 500
                          fontSize: 14,
                          height: 1.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                /// TRAILING ARROW
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFFCBD5E1), // Slate 300
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50 background

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              
              const SizedBox(height: 20),
              
              /// HEADER ICON
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF), // Indigo 50
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 36,
                  color: Color(0xFF4F46E5), // Indigo 600
                ),
              ),

              const SizedBox(height: 24),

              /// TITLE
              const Text(
                "Select Your Role",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A), // Slate 900
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              const Text(
                "Choose how you want to use PlacementHub",
                style: TextStyle(
                  color: Color(0xFF64748B), // Slate 500
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              /// ROLE CARDS
              _buildRoleCard(
                icon: Icons.person_outline_rounded,
                title: "Student",
                subtitle: "Browse jobs, apply, and track applications efficiently",
                color: const Color(0xFF4F46E5), // Indigo 600
                bgColor: const Color(0xFFEEF2FF), // Indigo 50
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentDashboard(),
                    ),
                  );
                },
              ),

              _buildRoleCard(
                icon: Icons.business_center_outlined,
                title: "Recruiter",
                subtitle: "Post job opportunities and manage suitable candidates",
                color: const Color(0xFF9333EA), // Purple 600
                bgColor: const Color(0xFFFAF5FF), // Purple 50
                onTap: () {
                  // Add Recruiter Dashboard Navigation
                },
              ),

              _buildRoleCard(
                icon: Icons.admin_panel_settings_outlined,
                title: "Administrator",
                subtitle: "Manage the placement process, roles, and view analytics",
                color: const Color(0xFF0D9488), // Teal 600
                bgColor: const Color(0xFFF0FDFA), // Teal 50
                onTap: () {
                  // Add Admin Dashboard Navigation
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

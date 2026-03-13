import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:placement_portal_app/screens/edit_profile_screen.dart';
import 'package:placement_portal_app/screens/login_screen.dart';
import 'package:placement_portal_app/screens/change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool jobAlerts = true;
  bool applicationUpdates = true;
  bool interviewReminders = true;

  /// Modern helper widget for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B), // Slate 500
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Modern Clickable Settings Tile
  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A), // Slate 900
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFCBD5E1), // Slate 300
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modern Toggle Setting Tile
  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B), // Slate 800
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF4F46E5), // Indigo 600
                inactiveTrackColor: const Color(0xFFE2E8F0), // Slate 200
                inactiveThumbColor: Colors.white,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            color: Color(0xFFF1F5F9), // Slate 100
            height: 1,
            indent: 64,
            endIndent: 16,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50

      body: Column(
        children: [
          /// MODERN HEADER
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 20,
              bottom: 30,
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
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  /// ACCOUNT SECTION
                  _buildSectionHeader("ACCOUNT"),
                  
                  _buildSettingsTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: const Color(0xFF4F46E5), // Indigo 600
                    iconBgColor: const Color(0xFFEEF2FF), // Indigo 50
                    title: "Edit Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: const Color(0xFF0D9488), // Teal 600
                    iconBgColor: const Color(0xFFF0FDFA), // Teal 50
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  /// NOTIFICATIONS SECTION
                  _buildSectionHeader("NOTIFICATIONS"),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        _buildToggleTile(
                          icon: Icons.work_outline_rounded,
                          iconColor: const Color(0xFFF59E0B), // Amber 500
                          iconBgColor: const Color(0xFFFEF3C7), // Amber 100
                          title: "Job Alerts",
                          value: jobAlerts,
                          onChanged: (value) => setState(() => jobAlerts = value),
                        ),
                        _buildToggleTile(
                          icon: Icons.update_rounded,
                          iconColor: const Color(0xFF3B82F6), // Blue 500
                          iconBgColor: const Color(0xFFEFF6FF), // Blue 50
                          title: "Application Updates",
                          value: applicationUpdates,
                          onChanged: (value) => setState(() => applicationUpdates = value),
                        ),
                        _buildToggleTile(
                          icon: Icons.event_available_rounded,
                          iconColor: const Color(0xFF8B5CF6), // Purple 500
                          iconBgColor: const Color(0xFFF5F3FF), // Purple 50
                          title: "Interview Reminders",
                          value: interviewReminders,
                          onChanged: (value) => setState(() => interviewReminders = value),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// SUPPORT SECTION
                  _buildSectionHeader("SUPPORT"),
                  
                  _buildSettingsTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF64748B), // Slate 500
                    iconBgColor: const Color(0xFFF1F5F9), // Slate 100
                    title: "Help & FAQ",
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: const Color(0xFF64748B), // Slate 500
                    iconBgColor: const Color(0xFFF1F5F9), // Slate 100
                    title: "Privacy Policy",
                    onTap: () {},
                  ),

                  const SizedBox(height: 48),

                  /// LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFE11D48)), // Rose 600
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Color(0xFFE11D48),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF1F2), // Rose 50
                        foregroundColor: const Color(0xFFE11D48), // Splash color
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// APP VERSION
                  const Center(
                    child: Text(
                      "PlacementHub v1.0.0",
                      style: TextStyle(
                        color: Color(0xFF94A3B8), // Slate 400
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

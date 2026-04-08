import 'package:flutter/material.dart';
import 'admin_utils.dart';
import 'admin_widgets.dart';

class SettingsTab extends StatelessWidget {
  final VoidCallback onSignOut;

  const SettingsTab({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AdminTheme.slate900),
          ),
          const SizedBox(height: 24),
          const AdminSettingsTile(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Manage alert preferences'),
          const AdminSettingsTile(icon: Icons.security_outlined, title: 'Security', subtitle: 'Password and 2FA settings'),
          const AdminSettingsTile(icon: Icons.tune_outlined, title: 'Portal Config', subtitle: 'Configure placement rules'),
          const AdminSettingsTile(icon: Icons.bar_chart_outlined, title: 'Analytics', subtitle: 'Placement statistics'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onSignOut,
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
}

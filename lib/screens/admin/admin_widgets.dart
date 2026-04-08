import 'package:flutter/material.dart';
import 'admin_utils.dart';

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminTheme.slate100),
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
              color: AdminTheme.slate900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AdminTheme.slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminActivityRow extends StatelessWidget {
  final String actor;
  final String action;
  final String time;
  final Color dotColor;

  const AdminActivityRow({
    super.key,
    required this.actor,
    required this.action,
    required this.time,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: const TextStyle(fontSize: 14, color: AdminTheme.slate700),
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
                  style: const TextStyle(fontSize: 12, color: AdminTheme.slate500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminUserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final Color roleColor;

  const AdminUserCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.slate100),
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
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
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
                    color: AdminTheme.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                color: roleColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AdminSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.slate100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AdminTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AdminTheme.primary, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.slate900)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AdminTheme.slate500, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AdminTheme.slate500),
      ),
    );
  }
}

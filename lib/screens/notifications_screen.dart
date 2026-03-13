import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  /// Modern Notification Card
  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String message,
    required String date,
    required bool isNew,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFFF8FAFC) : Colors.white, // Very subtle background for new
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNew ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          /// ICON CONTAINER
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14), // Squircle
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),

          const SizedBox(width: 16),

          /// TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isNew ? FontWeight.bold : FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0xFF0F172A), // Slate 900
                        ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        margin: const EdgeInsets.only(top: 4, left: 8),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4F46E5), // Indigo 600
                          shape: BoxShape.circle,
                        ),
                      )
                  ],
                ),
                
                const SizedBox(height: 6),
                
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF64748B), // Slate 500
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)), // Slate 400
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8), // Slate 400
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
      backgroundColor: const Color(0xFFF8FAFC), // Modern slate-50 background

      body: Column(
        children: [
          
          /// MODERN HEADER
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10, // Safe area top
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                /// BACK BUTTON
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

                /// TITLE & SUBTITLE
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        "Notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Stay updated with the latest news",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),

                /// UNREAD BADGE
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B), // Amber 500
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  ),
                  child: const Text(
                    "2 New",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// NOTIFICATION LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              children: [
                _buildNotificationCard(
                  icon: Icons.work_outline_rounded,
                  iconColor: const Color(0xFF3B82F6), // Blue 500
                  iconBgColor: const Color(0xFFEFF6FF), // Blue 50
                  title: "New Job Posted",
                  message: "Apple has posted a new job opening for iOS Developer.",
                  date: "Mar 2, 2026",
                  isNew: true,
                ),

                _buildNotificationCard(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF10B981), // Emerald 500
                  iconBgColor: const Color(0xFFECFDF5), // Emerald 50
                  title: "Application Shortlisted",
                  message: "Congratulations! You have been shortlisted for Software Engineer at Google.",
                  date: "Mar 3, 2026",
                  isNew: true,
                ),

                _buildNotificationCard(
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF8B5CF6), // Purple 500
                  iconBgColor: const Color(0xFFF5F3FF), // Purple 50
                  title: "Interview Scheduled",
                  message: "Your interview for Google is scheduled on March 8, 2026 at 10:00 AM.",
                  date: "Mar 4, 2026",
                  isNew: false,
                ),

                _buildNotificationCard(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF64748B), // Slate 500
                  iconBgColor: const Color(0xFFF1F5F9), // Slate 100
                  title: "Placement Drive Announcement",
                  message: "TCS campus drive will be conducted on March 15, 2026. Please prepare your docs.",
                  date: "Mar 1, 2026",
                  isNew: false,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

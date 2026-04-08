import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatDate(Timestamp? ts) {
    if (ts == null) return 'Just now';
    return DateFormat('MMM d, yyyy • h:mm a').format(ts.toDate());
  }

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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          List<QueryDocumentSnapshot> docs = [];

          if (snapshot.hasData) {
            docs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final target = data['targetUserId'] as String?;
              return target == 'all' || target == uid;
            }).toList();

            docs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final Timestamp? tsA = aData['createdAt'];
              final Timestamp? tsB = bData['createdAt'];
              
              if (tsA == null && tsB == null) return 0;
              if (tsA == null) return 1;
              if (tsB == null) return -1;
              
              return tsB.compareTo(tsA);
            });
          }

          int newCount = docs.where((d) => (d.data() as Map<String, dynamic>)['isNew'] == true).length;

          return Column(
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
                    if (newCount > 0)
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
                        child: Text(
                          "$newCount New",
                          style: const TextStyle(
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
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                    : docs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
                                SizedBox(height: 16),
                                Text('You\'re all caught up!', style: TextStyle(color: Color(0xFF64748B))),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              
                              final type = data['type'] as String? ?? 'general';
                              
                              IconData iconData = Icons.info_outline_rounded;
                              Color iconColor = const Color(0xFF64748B);
                              Color iconBgColor = const Color(0xFFF1F5F9);
                              
                              if (type == 'job') {
                                iconData = Icons.work_outline_rounded;
                                iconColor = const Color(0xFF3B82F6);
                                iconBgColor = const Color(0xFFEFF6FF);
                              } else if (type == 'interview') {
                                iconData = Icons.calendar_month_outlined;
                                iconColor = const Color(0xFF8B5CF6);
                                iconBgColor = const Color(0xFFF5F3FF);
                              } else if (type == 'status') {
                                iconData = Icons.description_outlined;
                                iconColor = const Color(0xFF10B981);
                                iconBgColor = const Color(0xFFECFDF5);
                              }

                              return _buildNotificationCard(
                                icon: iconData,
                                iconColor: iconColor,
                                iconBgColor: iconBgColor,
                                title: data['title'] ?? 'Notification',
                                message: data['message'] ?? '',
                                date: _formatDate(data['createdAt'] as Timestamp?),
                                isNew: data['isNew'] == true,
                              );
                            },
                          ),
              )
            ],
          );
        }
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_utils.dart';
import 'admin_widgets.dart';

class DashboardTab extends StatelessWidget {
  final VoidCallback onSignOut;

  const DashboardTab({super.key, required this.onSignOut});

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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnap) {
        int studentCount = 1; // 1 hardcoded in auth_service
        int staffCount = 2; // 2 hardcoded in auth_service

        if (userSnap.hasData) {
          for (var doc in userSnap.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final role = data['role'] as String?;
            if (role == 'student') {
              studentCount++;
            } else if (role == 'admin' || role == 'placementCell') {
              staffCount++;
            }
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
          builder: (context, jobSnap) {
            int activeJobs = 0;
            if (jobSnap.hasData) {
              activeJobs = jobSnap.data!.docs
                  .where((j) => (j.data() as Map<String, dynamic>)['status'] == 'Active')
                  .length;
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('applications').snapshots(),
              builder: (context, appSnap) {
                int totalApps = 0;
                int offerCount = 0;
                int pendingCount = 0;

                if (appSnap.hasData) {
                  final apps = appSnap.data!.docs;
                  totalApps = apps.length;
                  for (var d in apps) {
                    final st = (d.data() as Map<String, dynamic>)['status'];
                    if (st == 'Offer') offerCount++;
                    else if (st != 'Rejected') pendingCount++;
                  }
                }

                // Recent Activity Logic
                List<Map<String, dynamic>> activities = [];
                if (jobSnap.hasData) {
                  for (var doc in jobSnap.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['createdAt'] != null) {
                      activities.add({
                        'actor': data['company'] ?? 'A Company',
                        'action': 'posted a new role',
                        'time': data['createdAt'],
                        'color': const Color(0xFF4F46E5),
                      });
                    }
                  }
                }
                if (appSnap.hasData) {
                  for (var doc in appSnap.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['appliedAt'] != null) {
                      activities.add({
                        'actor': data['studentName'] ?? 'A Student',
                        'action': 'applied to ${data['company'] ?? 'a job'}',
                        'time': data['appliedAt'],
                        'color': const Color(0xFF10B981),
                      });
                    }
                  }
                }

                activities.sort((a, b) {
                  final tsA = a['time'] as Timestamp;
                  final tsB = b['time'] as Timestamp;
                  return tsB.compareTo(tsA);
                });

                final topActivities = activities.take(4).toList();

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
                                GestureDetector(
                                  onTap: onSignOut,
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
                                _buildGlassStatCard('Total Users', (studentCount + staffCount).toString(), Icons.people_rounded),
                                _buildGlassStatCard('Active Jobs', activeJobs.toString(), Icons.work_rounded),
                                _buildGlassStatCard('Placed', offerCount.toString(), Icons.check_circle_rounded),
                                _buildGlassStatCard('Pending', pendingCount.toString(), Icons.hourglass_top_rounded),
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
                                color: AdminTheme.slate900,
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
                                AdminStatCard(title: 'Students', value: studentCount.toString(), icon: Icons.school_rounded, color: const Color(0xFF4F46E5), bgColor: const Color(0xFFEEF2FF)),
                                AdminStatCard(title: 'Staff', value: staffCount.toString(), icon: Icons.business_rounded, color: const Color(0xFF9333EA), bgColor: const Color(0xFFFAF5FF)),
                                AdminStatCard(title: 'Applications', value: totalApps.toString(), icon: Icons.description_rounded, color: const Color(0xFF0D9488), bgColor: const Color(0xFFF0FDFA)),
                                AdminStatCard(title: 'Offers Made', value: offerCount.toString(), icon: Icons.handshake_rounded, color: const Color(0xFFF59E0B), bgColor: const Color(0xFFFEF3C7)),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // ── RECENT ACTIVITY ──────────────────────────
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AdminTheme.slate900,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Container(
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
                              child: topActivities.isEmpty
                                  ? const Text("No recent activity", style: TextStyle(color: AdminTheme.slate500))
                                  : Column(
                                      children: [
                                        for (int i = 0; i < topActivities.length; i++) ...[
                                          AdminActivityRow(
                                              actor: topActivities[i]['actor'],
                                              action: topActivities[i]['action'],
                                              time: AdminUtils.timeAgo(topActivities[i]['time'] as Timestamp),
                                              dotColor: topActivities[i]['color']),
                                          if (i < topActivities.length - 1)
                                            const Divider(color: AdminTheme.slate200, height: 1),
                                        ]
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
              },
            );
          },
        );
      },
    );
  }
}

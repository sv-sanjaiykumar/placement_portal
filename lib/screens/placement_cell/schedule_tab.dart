import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'placement_utils.dart';
import 'placement_widgets.dart';
import 'schedule_sheet.dart';

class ScheduleTab extends StatelessWidget {
  final BuildContext ctx;
  const ScheduleTab({super.key, required this.ctx});

  void _openScheduleSheet(String uid) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScheduleInterviewSheet(placementUid: uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            left: 24, right: 24, bottom: 20,
          ),
          color: Colors.white,
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Interview Schedule',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: PlacementTheme.slate900)),
                    SizedBox(height: 3),
                    Text('Upcoming interviews for shortlisted students',
                        style: TextStyle(color: PlacementTheme.slate500, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openScheduleSheet(uid),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlacementTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),

        // Main List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('applications').snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: PlacementTheme.primary));
              }
              if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

              final docsResponse = snap.data?.docs ?? [];
              final interviews = docsResponse.where((d) {
                final data = d.data() as Map<String, dynamic>;
                return data['status'] == 'Interview' || data['interviewDate'] != null;
              }).toList();

              if (interviews.isEmpty) {
                return const PlacementEmptyState(
                  title: 'No Interviews', 
                  sub: 'Tap "Schedule" to create one', 
                  icon: Icons.event_busy_rounded
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: interviews.length,
                itemBuilder: (ctx, i) {
                  final data = interviews[i].data() as Map<String, dynamic>;
                  final name = data['studentName'] ?? 'Unknown';
                  final role = '${data['jobTitle'] ?? ''} – ${data['company'] ?? ''}';
                  
                  // Format the time properly
                  final date = data['interviewDate'] ?? '';
                  final timeOfDay = data['interviewTime'] ?? '';
                  final timeStr = date.isNotEmpty ? '$date, $timeOfDay' : 'TBD';
                  
                  final mode = data['interviewMode'] ?? 'Online';
                  return _interviewCard(name, role, timeStr, mode);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _interviewCard(
      String name, String role, String time, String mode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PlacementTheme.slate100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: Color(0xFF4F46E5), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: PlacementTheme.slate900,
                        fontSize: 14)),
                Text(role,
                    style: const TextStyle(
                        fontSize: 12, color: PlacementTheme.slate500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: PlacementTheme.slate500),
                    const SizedBox(width: 3),
                    Text(time,
                        style: const TextStyle(
                            fontSize: 11,
                            color: PlacementTheme.slate500,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 10),
                    Icon(
                        mode == 'Online'
                            ? Icons.videocam_outlined
                            : Icons.location_on_outlined,
                        size: 11,
                        color: PlacementTheme.slate500),
                    const SizedBox(width: 3),
                    Text(mode,
                        style: const TextStyle(
                            fontSize: 11,
                            color: PlacementTheme.slate500,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

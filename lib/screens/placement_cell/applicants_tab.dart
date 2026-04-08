import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'placement_utils.dart';
import 'placement_widgets.dart';

class ApplicantsTab extends StatelessWidget {
  final String? jobIdFilter;
  final VoidCallback? onClearFilter;

  const ApplicantsTab({super.key, this.jobIdFilter, this.onClearFilter});

  @override
  Widget build(BuildContext context) {
    // If a filter is applied, we query for that specific jobId.
    // Otherwise, we get all applications ordered by appliedAt.
    Stream<QuerySnapshot> appStream;
    if (jobIdFilter != null) {
      appStream = FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobIdFilter)
          .snapshots();
    } else {
      appStream = FirebaseFirestore.instance
          .collection('applications')
          .orderBy('appliedAt', descending: true)
          .snapshots();
    }

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            left: 24, right: 24, bottom: 20,
          ),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Applicants',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: PlacementTheme.slate900)),
                        SizedBox(height: 3),
                        Text('All student applications — tap to update status',
                            style: TextStyle(color: PlacementTheme.slate500, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              if (jobIdFilter != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: PlacementTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PlacementTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list_rounded, size: 16, color: PlacementTheme.primary),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Showing students for selected job',
                          style: TextStyle(color: PlacementTheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      GestureDetector(
                        onTap: onClearFilter,
                        child: const Icon(Icons.close_rounded, size: 16, color: PlacementTheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),

        // ── Live applications stream ──────────────────────
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: appStream,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: PlacementTheme.primary));
              }
              if (snap.hasError) {
                return Center(
                    child: Text('Error: ${snap.error}'));
              }

              final docsResponse = snap.data?.docs ?? [];
              
              // If we used a where clause, Firestore strips ordering unless we have a composite index.
              // So we sort locally just to be safe.
              final docs = docsResponse.toList();
              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final tsA = dataA['appliedAt'] as Timestamp?;
                final tsB = dataB['appliedAt'] as Timestamp?;
                if (tsA == null || tsB == null) return 0;
                return tsB.compareTo(tsA);
              });

              if (docs.isEmpty) {
                return const PlacementEmptyState(
                    title: 'No Applications Yet',
                    sub: 'Applications will appear here once students apply',
                    icon: Icons.people_outline_rounded);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final doc  = docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  return _applicantCard(data, doc.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _applicantCard(Map<String, dynamic> app, String docId) {
    final status = app['status'] ?? 'Applied';
    final color  = PlacementUtils.statusColor(status);
    final name   = app['studentName']  ?? 'Unknown';
    final email  = app['studentEmail'] ?? '';
    final dept   = app['studentDept']  ?? '';
    final role   = app['jobTitle']     ?? '';
    final co     = app['company']      ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PlacementTheme.slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: PlacementTheme.primary.withOpacity(0.12),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: PlacementTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              // Student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: PlacementTheme.slate900)),
                    const SizedBox(height: 2),
                    Text(email,
                        style: const TextStyle(
                            fontSize: 12, color: PlacementTheme.slate500)),
                    if (dept.isNotEmpty)
                      Text(dept,
                          style: const TextStyle(
                              fontSize: 11, color: PlacementTheme.slate500)),
                  ],
                ),
              ),
              // Status dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: DropdownButton<String>(
                  value: PlacementUtils.statusOptions.contains(status)
                      ? status
                      : 'Applied',
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: color),
                  items: PlacementUtils.statusOptions.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s,
                          style: TextStyle(
                              color: PlacementUtils.statusColor(s),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      PlacementUtils.updateStatus(docId, newStatus);
                    }
                  },
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child:
                Divider(height: 1, color: Color(0xFFF1F5F9), thickness: 1),
          ),

          // Applied for info + date
          Row(
            children: [
              const Icon(Icons.work_outline_rounded,
                  size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$role  ·  $co',
                  style: const TextStyle(
                      color: PlacementTheme.slate500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(PlacementUtils.fmt(app['appliedAt']),
                      style: const TextStyle(
                          color: PlacementTheme.slate500, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

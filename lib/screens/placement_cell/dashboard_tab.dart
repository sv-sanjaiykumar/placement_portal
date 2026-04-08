import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../post_job_screen.dart';
import 'placement_utils.dart';
import 'placement_widgets.dart';

class DashboardTab extends StatelessWidget {
  final void Function(String) onViewApplicants;
  final VoidCallback onSignOut;

  const DashboardTab({
    super.key,
    required this.onViewApplicants,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Gradient header ───────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24, right: 24, bottom: 32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
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
                        Text('Placement Cell 🏢',
                            style: TextStyle(
                                color: Colors.purple.shade100,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        const Text('Placement Cell',
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5)),
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
                        child: const Icon(Icons.logout_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Summary stat cards (from Firestore) ────
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('jobs')
                      .where('postedBy', isEqualTo: uid)
                      .snapshots(),
                  builder: (ctx, jobSnap) {
                    final totalJobs = jobSnap.data?.docs.length ?? 0;
                    final activeJobs = jobSnap.data?.docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return data['status'] == 'Active';
                    }).length ?? 0;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('applications')
                          .snapshots(),
                      builder: (ctx, appSnap) {
                        final totalApps = appSnap.data?.docs.length ?? 0;
                        final shortlisted = appSnap.data?.docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return data['status'] == 'Shortlisted';
                        }).length ?? 0;

                        return Row(
                          children: [
                            Expanded(child: _glassCard(
                                'Job Posts', '$totalJobs',
                                Icons.work_rounded)),
                            const SizedBox(width: 10),
                            Expanded(child: _glassCard(
                                'Active', '$activeJobs',
                                Icons.check_circle_outline_rounded)),
                            const SizedBox(width: 10),
                            Expanded(child: _glassCard(
                                'Applicants', '$totalApps',
                                Icons.people_rounded)),
                            const SizedBox(width: 10),
                            Expanded(child: _glassCard(
                                'Shortlisted', '$shortlisted',
                                Icons.star_outline_rounded)),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Post Job Button ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PostJobScreen()),
                    ),
                    icon: const Icon(Icons.add_rounded,
                        color: Colors.white),
                    label: const Text('Post a New Job',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlacementTheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Live job list ───────────────────────────
                const Text('Your Job Postings',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: PlacementTheme.slate900)),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('jobs')
                      .where('postedBy', isEqualTo: uid)
                      .snapshots(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: PlacementTheme.primary),
                      ));
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final docsResponse = snap.data?.docs ?? [];
                    if (docsResponse.isEmpty) {
                      return const PlacementEmptyState(
                          title: 'No jobs posted yet',
                          sub: 'Tap "Post a New Job" above to get started',
                          icon: Icons.work_off_outlined);
                    }
                    
                    // Sort locally
                    final docs = docsResponse.toList();
                    docs.sort((a, b) {
                      final dataA = a.data() as Map<String, dynamic>;
                      final dataB = b.data() as Map<String, dynamic>;
                      final tsA = dataA['createdAt'] as Timestamp?;
                      final tsB = dataB['createdAt'] as Timestamp?;
                      if (tsA == null || tsB == null) return 0;
                      return tsB.compareTo(tsA);
                    });

                    return Column(
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _jobCard(data, doc.id);
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _jobCard(Map<String, dynamic> job, String jobId) {
    final status    = job['status'] ?? 'Active';
    final isActive  = status == 'Active';
    final statusClr = isActive
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .snapshots(),
      builder: (ctx, appSnap) {
        final appCount = appSnap.data?.docs.length ?? 0;

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
                blurRadius: 15, offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PlacementTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.work_outline_rounded,
                        color: PlacementTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: PlacementTheme.slate900)),
                        Text(job['company'] ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: PlacementTheme.slate500)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusClr.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            color: statusClr,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoChip(Icons.payments_outlined,
                      job['salary'] ?? 'N/A',
                      const Color(0xFF10B981),
                      const Color(0xFFECFDF5)),
                  const SizedBox(width: 8),
                  _infoChip(Icons.people_outline,
                      '$appCount Applicant${appCount == 1 ? '' : 's'}',
                      PlacementTheme.primary, PlacementTheme.primaryLight),
                  const SizedBox(width: 8),
                  _infoChip(Icons.location_on_outlined,
                      job['location'] ?? '',
                      PlacementTheme.slate700, PlacementTheme.slate100),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onViewApplicants(jobId),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: PlacementTheme.slate200),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        foregroundColor: PlacementTheme.slate700,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('View Applicants',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('jobs')
                            .doc(jobId)
                            .update({
                          'status': isActive ? 'Closed' : 'Active'
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isActive ? const Color(0xFFEF4444) : PlacementTheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(isActive ? 'Close Job' : 'Reopen',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

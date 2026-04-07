// ============================================================
// placement_cell_dashboard.dart
// Dashboard for the Placement Cell.
// – Dashboard tab: streams posted jobs from Firestore live
// – Applicants tab: streams all applications with student info
// – Schedule tab: interview management (static for now)
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'post_job_screen.dart';

class PlacementCellDashboard extends StatefulWidget {
  const PlacementCellDashboard({super.key});

  @override
  State<PlacementCellDashboard> createState() =>
      _PlacementCellDashboardState();
}

class _PlacementCellDashboardState extends State<PlacementCellDashboard> {
  int _currentIndex = 0;

  // ── Palette ───────────────────────────────────────────────
  static const Color _primary      = Color(0xFF9333EA); // Purple 600
  static const Color _primaryLight = Color(0xFFFAF5FF); // Purple 50
  static const Color _slate900     = Color(0xFF0F172A);
  static const Color _slate700     = Color(0xFF334155);
  static const Color _slate500     = Color(0xFF64748B);
  static const Color _slate200     = Color(0xFFE2E8F0);
  static const Color _slate100     = Color(0xFFF1F5F9);
  static const Color _slate50      = Color(0xFFF8FAFC);

  // ── Application status options ────────────────────────────
  static const List<String> _statusOptions = [
    'Applied', 'Shortlisted', 'Interview', 'Offer', 'Rejected',
  ];

  static Color _statusColor(String s) {
    switch (s) {
      case 'Shortlisted': return const Color(0xFF10B981);
      case 'Interview':   return const Color(0xFF4F46E5);
      case 'Offer':       return const Color(0xFFF59E0B);
      case 'Rejected':    return const Color(0xFFEF4444);
      default:            return const Color(0xFF3B82F6);
    }
  }

  // ── Date formatter ────────────────────────────────────────
  String _fmt(dynamic ts) {
    if (ts == null) return '—';
    try {
      return DateFormat('MMM d, yyyy').format((ts as Timestamp).toDate());
    } catch (_) {
      return '—';
    }
  }

  // ── Sign out ──────────────────────────────────────────────
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  // ── Update application status by placement cell ───────────
  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(docId)
        .update({'status': newStatus});
  }

  // ─────────────────────────────────────────────────────────
  // DASHBOARD TAB — live job postings created by this user
  // ─────────────────────────────────────────────────────────
  Widget _buildDashboardContent() {
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
                      onTap: _signOut,
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
                      backgroundColor: _primary,
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
                        color: _slate900)),
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
                        child: CircularProgressIndicator(color: _primary),
                      ));
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final docsResponse = snap.data?.docs ?? [];
                    if (docsResponse.isEmpty) {
                      return _emptyState(
                          'No jobs posted yet',
                          'Tap "Post a New Job" above to get started',
                          Icons.work_off_outlined);
                    }
                    
                    // Sort locally to avoid composite index requirement
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

  // ── Job card ───────────────────────────────────────────────
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
            border: Border.all(color: _slate100),
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
                      color: _primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.work_outline_rounded,
                        color: _primary, size: 20),
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
                                color: _slate900)),
                        Text(job['company'] ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: _slate500)),
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
                      _primary, _primaryLight),
                  const SizedBox(width: 8),
                  _infoChip(Icons.location_on_outlined,
                      job['location'] ?? '',
                      _slate700, _slate100),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _currentIndex = 1);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _slate200),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        foregroundColor: _slate700,
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
                        // Toggle Active/Closed
                        FirebaseFirestore.instance
                            .collection('jobs')
                            .doc(jobId)
                            .update({
                          'status':
                              isActive ? 'Closed' : 'Active'
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isActive ? const Color(0xFFEF4444) : _primary,
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

  // ─────────────────────────────────────────────────────────
  // APPLICANTS TAB — all applications, streamed live
  // ─────────────────────────────────────────────────────────
  Widget _buildApplicantsContent() {
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
                    Text('Applicants',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _slate900)),
                    SizedBox(height: 3),
                    Text('All student applications — tap to update status',
                        style: TextStyle(color: _slate500, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),

        // ── Live applications stream ──────────────────────
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('applications')
                .orderBy('appliedAt', descending: true)
                .snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: _primary));
              }
              if (snap.hasError) {
                return Center(
                    child: Text('Error: ${snap.error}'));
              }

              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return _emptyState(
                    'No Applications Yet',
                    'Applications will appear here once students apply',
                    Icons.people_outline_rounded);
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

  // ── Applicant card with status dropdown ───────────────────
  Widget _applicantCard(Map<String, dynamic> app, String docId) {
    final status = app['status'] ?? 'Applied';
    final color  = _statusColor(status);
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
        border: Border.all(color: _slate100),
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
                backgroundColor: _primary.withOpacity(0.12),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: _primary,
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
                            color: _slate900)),
                    const SizedBox(height: 2),
                    Text(email,
                        style: const TextStyle(
                            fontSize: 12, color: _slate500)),
                    if (dept.isNotEmpty)
                      Text(dept,
                          style: const TextStyle(
                              fontSize: 11, color: _slate500)),
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
                  value: _statusOptions.contains(status)
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
                  items: _statusOptions.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s,
                          style: TextStyle(
                              color: _statusColor(s),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      _updateStatus(docId, newStatus);
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
                      color: _slate500,
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
                  Text(_fmt(app['appliedAt']),
                      style: const TextStyle(
                          color: _slate500, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // SCHEDULE TAB
  // ─────────────────────────────────────────────────────────
  Widget _buildScheduleContent() {
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
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _slate900)),
                    SizedBox(height: 3),
                    Text('Upcoming interviews for shortlisted students',
                        style: TextStyle(color: _slate500, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openScheduleSheet(uid),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
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
                return const Center(child: CircularProgressIndicator(color: _primary));
              }
              if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

              final docsResponse = snap.data?.docs ?? [];
              final interviews = docsResponse.where((d) {
                final data = d.data() as Map<String, dynamic>;
                return data['status'] == 'Interview' || data['interviewDate'] != null;
              }).toList();

              if (interviews.isEmpty) {
                return _emptyState('No Interviews', 'Tap "Schedule" to create one', Icons.event_busy_rounded);
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

  void _openScheduleSheet(String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ScheduleInterviewSheet(placementUid: uid),
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
        border: Border.all(color: _slate100),
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
                        color: _slate900,
                        fontSize: 14)),
                Text(role,
                    style: const TextStyle(
                        fontSize: 12, color: _slate500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: _slate500),
                    const SizedBox(width: 3),
                    Text(time,
                        style: const TextStyle(
                            fontSize: 11,
                            color: _slate500,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 10),
                    Icon(
                        mode == 'Online'
                            ? Icons.videocam_outlined
                            : Icons.location_on_outlined,
                        size: 11,
                        color: _slate500),
                    const SizedBox(width: 3),
                    Text(mode,
                        style: const TextStyle(
                            fontSize: 11,
                            color: _slate500,
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

  // ── Shared helpers ────────────────────────────────────────
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

  Widget _emptyState(String title, String sub, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  color: _primaryLight, shape: BoxShape.circle),
              child: Icon(icon, color: _primary, size: 36),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _slate900)),
            const SizedBox(height: 6),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _slate500, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: _primary,
          unselectedItemColor: _slate500,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded), label: 'Applicants'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded),
                label: 'Schedule'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardContent(),
          _buildApplicantsContent(),
          _buildScheduleContent(),
        ],
      ),
    );
  }
}

class _ScheduleInterviewSheet extends StatefulWidget {
  final String placementUid;
  const _ScheduleInterviewSheet({required this.placementUid});

  @override
  State<_ScheduleInterviewSheet> createState() => _ScheduleInterviewSheetState();
}

class _ScheduleInterviewSheetState extends State<_ScheduleInterviewSheet> {
  String? _selectedJobId;
  String? _selectedAppId;
  
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _modeController = TextEditingController(text: 'Online');

  bool _loading = false;

  Future<void> _submit() async {
    if (_selectedAppId == null || _dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('applications').doc(_selectedAppId).update({
        'status': 'Interview',
        'interviewDate': _dateController.text,
        'interviewTime': _timeController.text,
        'interviewMode': _modeController.text,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Schedule Interview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('jobs').where('postedBy', isEqualTo: widget.placementUid).snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) return const LinearProgressIndicator();
              final docs = snap.data!.docs;
              return DropdownButtonFormField<String>(
                value: _selectedJobId,
                decoration: InputDecoration(
                  labelText: 'Select Job', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return DropdownMenuItem(value: d.id, child: Text(data['title'] ?? 'Unknown'));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedJobId = v;
                    _selectedAppId = null;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 12),
          
          if (_selectedJobId != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('applications').where('jobId', isEqualTo: _selectedJobId).snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const LinearProgressIndicator();
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Text('No applicants yet for this job', style: TextStyle(color: Colors.grey));
                
                return DropdownButtonFormField<String>(
                  value: _selectedAppId,
                  decoration: InputDecoration(
                    labelText: 'Select Applicant', 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return DropdownMenuItem(value: d.id, child: Text('${data['studentName']} (${data['status']})'));
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedAppId = v;
                    });
                  },
                );
              },
            ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _dateController, 
            decoration: InputDecoration(labelText: 'Date (e.g. Apr 10, 2025)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _timeController, 
            decoration: InputDecoration(labelText: 'Time (e.g. 10:00 AM)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modeController, 
            decoration: InputDecoration(labelText: 'Mode (Online / On-site)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9333EA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirm Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// application_screen.dart  (Student side)
// Shows the current student's applications streamed live from
// Firestore /applications where studentUid == current user.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All', 'Applied', 'Shortlisted', 'Interview', 'Offer', 'Rejected'
  ];

  // ── Status → color ────────────────────────────────────────
  static Color _statusColor(String status) {
    switch (status) {
      case 'Shortlisted': return const Color(0xFF10B981);
      case 'Interview':   return const Color(0xFF4F46E5);
      case 'Offer':       return const Color(0xFFF59E0B);
      case 'Rejected':    return const Color(0xFFEF4444);
      default:            return const Color(0xFF3B82F6); // Applied
    }
  }

  // ── Status → icon ─────────────────────────────────────────
  static IconData _statusIcon(String status) {
    switch (status) {
      case 'Shortlisted': return Icons.check_circle_outline_rounded;
      case 'Interview':   return Icons.calendar_today_rounded;
      case 'Offer':       return Icons.handshake_outlined;
      case 'Rejected':    return Icons.cancel_outlined;
      default:            return Icons.send_rounded;
    }
  }

  // ── Format Firestore timestamp ────────────────────────────
  String _formatDate(dynamic ts) {
    if (ts == null) return '—';
    try {
      final dt = (ts as Timestamp).toDate();
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── GRADIENT HEADER ───────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20, right: 20, bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Applications',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Track your application status in real-time',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          // ── FILTER CHIPS ──────────────────────────────────
          SizedBox(
            height: 56,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, i) {
                final f = _filters[i];
                final selected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(f,
                        style: TextStyle(
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF64748B))),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedFilter = f),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF4F46E5),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFE2E8F0),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          // ── APPLICATION LIST (live Firestore) ─────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  .where('studentUid', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4F46E5)));
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(
                              color: Color(0xFF64748B))));
                }

                var docsResponse = snapshot.data?.docs ?? [];
                
                // Sort locally to avoid composite index requirement
                var docs = docsResponse.toList();
                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final tsA = dataA['appliedAt'] as Timestamp?;
                  final tsB = dataB['appliedAt'] as Timestamp?;
                  if (tsA == null || tsB == null) return 0;
                  return tsB.compareTo(tsA);
                });

                // Filter by status
                if (_selectedFilter != 'All') {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['status'] == _selectedFilter;
                  }).toList();
                }

                if (docs.isEmpty) return _buildEmpty();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return _buildCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Application Card ──────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> app) {
    final status    = app['status'] ?? 'Applied';
    final color     = _statusColor(status);
    final icon      = _statusIcon(status);
    final company   = app['company'] ?? '';
    final logoColor = [
      const Color(0xFFEF4444), const Color(0xFF3B82F6),
      const Color(0xFF10B981), const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ][company.length % 5];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: logoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    company.isNotEmpty ? company[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: logoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app['jobTitle'] ?? 'Unknown Role',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(company,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(status,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9),
                thickness: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 5),
                  Text('Applied: ${_formatDate(app['appliedAt'])}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: Color(0xFFCBD5E1)),
            ],
          ),

          if (app['interviewDate'] != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Interview: ${app['interviewDate']} at ${app['interviewTime'] ?? 'TBD'} · ${app['interviewMode'] ?? 'Online'}',
                      style: const TextStyle(
                        fontSize: 12, 
                        color: Color(0xFF4F46E5), 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_outlined,
                  color: Color(0xFF4F46E5), size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedFilter == 'All'
                  ? 'No Applications Yet'
                  : 'No "$_selectedFilter" Applications',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text('Browse Jobs and hit Apply Now!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

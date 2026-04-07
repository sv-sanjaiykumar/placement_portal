import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> job;
  final String jobId;

  const JobDetailsScreen({
    super.key,
    required this.job,
    required this.jobId,
  });

  // ── Theme constants ─────────────────────────────────────────
  static const Color _primary = Color(0xFF4F46E5);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate100 = Color(0xFFF1F5F9);
  static const Color _slate50  = Color(0xFFF8FAFC);

  // ── Color from company name initial ──────────────────────
  Color _logoColor(String company) {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];
    return colors[company.length % colors.length];
  }

  // ── Handle Job Application ──────────────────────────────────
  Future<void> _applyForJob(BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack(ctx, 'Please log in to apply.', const Color(0xFFEF4444));
      return;
    }

    try {
      // Fetch student data from users collection
      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final name = studentDoc.data()?['name'] ?? user.displayName ?? 'Student';
      final dept = studentDoc.data()?['department'] ?? 'N/A';
      final email = studentDoc.data()?['email'] ?? user.email ?? '';

      // Write application to Firestore
      await FirebaseFirestore.instance.collection('applications').add({
        'jobId': jobId,
        'jobTitle': job['title'] ?? '',
        'company': job['company'] ?? '',
        'studentUid': user.uid,
        'studentName': name,
        'studentEmail': email,
        'studentDept': dept,
        'status': 'Applied',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      if (ctx.mounted) {
        _showSnack(ctx, 'Application submitted for ${job['title']}!',
            const Color(0xFF10B981));
      }
    } catch (e) {
      if (ctx.mounted) {
        _showSnack(ctx, 'Failed to apply: $e', const Color(0xFFEF4444));
      }
    }
  }

  void _showSnack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final company = job['company'] ?? 'Unknown';
    final title = job['title'] ?? 'Role';
    final location = job['location'] ?? 'Not specified';
    final salary = job['salary'] ?? 'Not specified';
    final type = job['type'] ?? 'Full-time';
    final dept = job['department'] ?? 'Any';
    final cgpa = job['minCgpa'] ?? 'None';
    final description = job['description'] ?? 'No description provided by the recruiter.';
    final color = _logoColor(company);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _slate900,
        title: const Text("Job Details", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Block ──────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            company.isNotEmpty ? company[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _slate900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        company,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Metadata Grid ──────────────────────────────────
                Row(
                  children: [
                    Expanded(child: _buildMetaCard(Icons.payments_outlined, "Salary", salary, const Color(0xFF10B981))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetaCard(Icons.location_on_outlined, "Location", location, const Color(0xFF3B82F6))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMetaCard(Icons.work_outline_rounded, "Type", type, const Color(0xFFF59E0B))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetaCard(Icons.grade_outlined, "Min CGPA", cgpa, const Color(0xFF8B5CF6))),
                  ],
                ),
                
                const SizedBox(height: 32),

                // ── Department ─────────────────────────────────────
                const Text(
                  "Eligible Departments",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _slate900),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _slate100),
                  ),
                  child: Text(
                    dept,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: _slate500, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Description ─────────────────────────────────────
                const Text(
                  "Job Description",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _slate900),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: _slate500,
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky Bottom Apply Button ──────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  )
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                // Real-time check if this student has already applied
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('jobId', isEqualTo: jobId)
                    .where('studentUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
                    .snapshots(),
                builder: (context, snap) {
                  final alreadyApplied = snap.hasData && snap.data!.docs.isNotEmpty;

                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: alreadyApplied ? null : () => _applyForJob(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alreadyApplied ? const Color(0xFF10B981) : _primary,
                        disabledBackgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            alreadyApplied ? Icons.check_circle_rounded : Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            alreadyApplied ? 'Already Applied' : 'Apply Now',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetaCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _slate100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: _slate500, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _slate900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

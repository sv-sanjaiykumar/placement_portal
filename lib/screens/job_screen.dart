// ============================================================
// job_screen.dart  (Student side)
// Streams live job listings from Firestore /jobs.
// Students can apply — application is written to /applications.
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Palette ───────────────────────────────────────────────
  static const Color _primary      = Color(0xFF4F46E5);
  static const Color _slate900     = Color(0xFF0F172A);
  static const Color _slate500     = Color(0xFF64748B);
  static const Color _slate100     = Color(0xFFF1F5F9);
  static const Color _slate50      = Color(0xFFF8FAFC);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Color from company name initial ──────────────────────
  Color _logoColor(String company) {
    final colors = [
      const Color(0xFFEF4444), const Color(0xFF3B82F6),
      const Color(0xFF10B981), const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6), const Color(0xFF9333EA),
    ];
    return colors[company.length % colors.length];
  }

  // ── Job Card ──────────────────────────────────────────────
  Widget _buildJobCard(BuildContext ctx, Map<String, dynamic> job, String jobId) {
    final color   = _logoColor(job['company'] ?? 'A');
    final company = job['company'] ?? '';
    final title   = job['title']   ?? '';
    final salary  = job['salary']  ?? 'Not specified';
    final loc     = job['location'] ?? '';
    final type    = job['type']    ?? 'Full-time';
    final cgpa    = job['minCgpa'] ?? '0.0';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: _slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Top row ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    company.isNotEmpty ? company[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold, color: _slate900)),
                    const SizedBox(height: 3),
                    Text(company, style: const TextStyle(
                        fontSize: 13, color: _slate500, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              // Job type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(type,
                    style: const TextStyle(
                        color: _primary, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Meta chips ───────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip(Icons.location_on_outlined, loc,
                  const Color(0xFF6366F1), const Color(0xFFEEF2FF)),
              _chip(Icons.payments_outlined,    salary,
                  const Color(0xFF10B981), const Color(0xFFECFDF5)),
              if (cgpa != '0.0')
                _chip(Icons.grade_outlined, 'CGPA ≥ $cgpa',
                    const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9), thickness: 1),
          ),

          // ── View Details button ───────────────────────────
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(job: job, jobId: jobId),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFF0F172A), // Slate 900
              ),
              child: const Text(
                "View Details",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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
              child: const Icon(Icons.work_off_outlined,
                  color: _primary, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('No Jobs Available',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _slate900)),
            const SizedBox(height: 8),
            const Text('Check back later for new job postings',
                textAlign: TextAlign.center,
                style: TextStyle(color: _slate500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,
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
                Text('Job Opportunities',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Live postings from placement cell',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          // ── SEARCH BAR ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by job title or company...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF94A3B8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Color(0xFF94A3B8), size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _primary, width: 1.5),
                ),
              ),
            ),
          ),

          // ── JOB LIST (live from Firestore) ────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .where('status', isEqualTo: 'Active')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primary));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: _slate500)));
                }

                var docsResponse = snapshot.data?.docs ?? [];
                
                // Sort locally to avoid composite index requirement
                var docs = docsResponse.toList();
                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final tsA = dataA['createdAt'] as Timestamp?;
                  final tsB = dataB['createdAt'] as Timestamp?;
                  if (tsA == null || tsB == null) return 0;
                  return tsB.compareTo(tsA);
                });

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return (data['title']   ?? '').toString().toLowerCase()
                               .contains(_searchQuery) ||
                           (data['company'] ?? '').toString().toLowerCase()
                               .contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) return _buildEmpty();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final doc  = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildJobCard(ctx, data, doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

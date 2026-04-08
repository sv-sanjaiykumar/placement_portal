// ============================================================
// post_job_screen.dart
// Allows the Placement Cell to post a new job opening.
// The job is saved to Firestore /jobs/{docId} and immediately
// becomes visible to all students on the Jobs screen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────
  final _titleController       = TextEditingController();
  final _companyController     = TextEditingController();
  final _locationController    = TextEditingController();
  final _salaryController      = TextEditingController();
  final _departmentController  = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cgpaController        = TextEditingController();

  // ── Dropdown state ────────────────────────────────────────
  String _jobType     = 'Full-time';
  String _jobStatus   = 'Active';
  bool _loading       = false;
  bool _posted        = false;

  static const List<String> _jobTypes   = ['Full-time', 'Internship', 'Part-time', 'Contract'];
  static const List<String> _jobStatuses = ['Active', 'Closed'];

  // ── Colors ────────────────────────────────────────────────
  static const Color _primary  = Color(0xFF9333EA);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate200 = Color(0xFFE2E8F0);
  static const Color _slate50  = Color(0xFFF8FAFC);

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _departmentController.dispose();
    _descriptionController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  // ── Post job to Firestore ─────────────────────────────────
  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      // Write to /jobs collection — students stream from this
      await FirebaseFirestore.instance.collection('jobs').add({
        'title':       _titleController.text.trim(),
        'company':     _companyController.text.trim(),
        'location':    _locationController.text.trim(),
        'salary':      _salaryController.text.trim(),
        'department':  _departmentController.text.trim(),
        'description': _descriptionController.text.trim(),
        'minCgpa':     _cgpaController.text.trim().isEmpty ? '0.0' : _cgpaController.text.trim(),
        'type':        _jobType,
        'status':      _jobStatus,
        'postedBy':    uid,
        'createdAt':   FieldValue.serverTimestamp(),
      });

      // Fire a push notification to all students
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'New Job Posted',
        'message': '${_companyController.text.trim()} has posted a new job opening for ${_titleController.text.trim()}.',
        'type': 'job',
        'targetUserId': 'all',
        'createdAt': FieldValue.serverTimestamp(),
        'isNew': true,
      });

      if (!mounted) return;
      setState(() { _posted = true; });

      // Brief visual feedback before returning
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post job: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ── Reusable form field ───────────────────────────────────
  Widget _field({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _slate900)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 14, color: _slate900),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: maxLines == 1 ? Icon(icon, color: const Color(0xFF94A3B8), size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: maxLines > 1
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ── Dropdown field ────────────────────────────────────────
  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _slate900)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: _slate900),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Post a New Job',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header strip ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.work_outline_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Job Details',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                            'Fill in the details below. The job will be\nvisible to students immediately.',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _field(
                      label: 'Job Title *',
                      hint: 'e.g. Software Engineer',
                      icon: Icons.work_outline_rounded,
                      controller: _titleController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Job title is required'
                          : null,
                    ),

                    _field(
                      label: 'Company Name *',
                      hint: 'e.g. Google',
                      icon: Icons.business_outlined,
                      controller: _companyController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Company name is required'
                          : null,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            label: 'Location *',
                            hint: 'e.g. Bangalore',
                            icon: Icons.location_on_outlined,
                            controller: _locationController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: 'Salary / Package',
                            hint: 'e.g. ₹18–22 LPA',
                            icon: Icons.payments_outlined,
                            controller: _salaryController,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            label: 'Department',
                            hint: 'e.g. Computer Science',
                            icon: Icons.school_outlined,
                            controller: _departmentController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: 'Min. CGPA',
                            hint: 'e.g. 7.0',
                            icon: Icons.grade_outlined,
                            controller: _cgpaController,
                            keyboard: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _dropdown(
                            label: 'Job Type',
                            value: _jobType,
                            items: _jobTypes,
                            onChanged: (v) => setState(() => _jobType = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dropdown(
                            label: 'Status',
                            value: _jobStatus,
                            items: _jobStatuses,
                            onChanged: (v) => setState(() => _jobStatus = v!),
                          ),
                        ),
                      ],
                    ),

                    _field(
                      label: 'Job Description',
                      hint: 'Describe the role, responsibilities, and requirements...',
                      icon: Icons.description_outlined,
                      controller: _descriptionController,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 8),

                    // ── Submit button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _postJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _posted
                              ? const Color(0xFF10B981)
                              : _primary,
                          disabledBackgroundColor: _primary.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_posted)
                                    const Icon(Icons.check_circle_rounded,
                                        color: Colors.white, size: 22)
                                  else
                                    const SizedBox(
                                      height: 22, width: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2.5),
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _posted ? 'Job Posted!' : 'Posting Job...',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text('Post Job',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

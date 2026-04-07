// ============================================================
// create_student_screen.dart
// Allows the Admin to create a new student account.
//
// Uses a secondary Firebase App instance so that creating the
// new user does NOT sign out the currently-logged-in admin.
//
// On success, the new student's UID + role are stored in
// Firestore so they can log in and be redirected correctly.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class CreateStudentScreen extends StatefulWidget {
  const CreateStudentScreen({super.key});

  @override
  State<CreateStudentScreen> createState() => _CreateStudentScreenState();
}

class _CreateStudentScreenState extends State<CreateStudentScreen> {
  // ── Form key for validation ───────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Text controllers ──────────────────────────────────────
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _deptController     = TextEditingController();

  bool _loading       = false;
  bool _hidePassword  = true;
  bool _created       = false; // shows success state

  // ── Color Palette (Indigo theme for Student) ─────────────
  static const Color _primary      = Color(0xFF4F46E5); // Indigo 600
  static const Color _primaryLight = Color(0xFFEEF2FF); // Indigo 50
  static const Color _slate900     = Color(0xFF0F172A);
  static const Color _slate500     = Color(0xFF64748B);
  static const Color _slate200     = Color(0xFFE2E8F0);
  static const Color _slate100     = Color(0xFFF1F5F9);
  static const Color _slate50      = Color(0xFFF8FAFC);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  // ── Create student account ────────────────────────────────
  // Uses a secondary Firebase App so the admin stays signed in.
  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    FirebaseApp? secondaryApp;

    try {
      // ── Step 1: Spin up a temporary secondary Firebase app ─
      // This isolates the createUser call from the admin session.
      secondaryApp = await Firebase.initializeApp(
        name: 'StudentCreation_${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      // ── Step 2: Create the Firebase Auth account ───────────
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // ── Step 3: Store role + profile in Firestore ──────────
      // auth_service.dart reads this to redirect student correctly.
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid':        uid,
        'name':       _nameController.text.trim(),
        'email':      _emailController.text.trim().toLowerCase(),
        'role':       'student',
        'department': _deptController.text.trim(),
        'createdAt':  FieldValue.serverTimestamp(),
        'createdBy':  'admin',
      });

      // ── Step 4: Sign out from secondary app & clean up ─────
      await secondaryAuth.signOut();

      if (mounted) {
        setState(() {
          _loading = true;
          _created = true;
        });

        // Brief success pause, then reset form for next entry
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _loading = false;
            _created = false;
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _deptController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Student "${_nameController.text.isEmpty ? "account" : ""}" created successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _loading = false);

      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This email is already registered.\nUse a different email.';
          break;
        case 'weak-password':
          msg = 'Password must be at least 6 characters long.';
          break;
        case 'invalid-email':
          msg = 'The email address format is invalid.';
          break;
        default:
          msg = e.message ?? 'An error occurred. Please try again.';
      }
      _showError('Account Creation Failed', msg);
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _showError('Unexpected Error', 'Something went wrong:\n$e');
    } finally {
      // Always clean up the secondary app regardless of outcome
      await secondaryApp?.delete();
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(color: _slate500, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Styled input field ────────────────────────────────────
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _slate900,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _hidePassword : false,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _slate900),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
        const SizedBox(height: 16),
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
        title: const Text(
          'Create Student Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient header strip ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Student',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fill in the details to create a student login account',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
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

                    // ── Info banner ────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFF3B82F6), size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'The student can use these credentials to log in to the app.',
                              style: TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Full Name ──────────────────────────────
                    _buildField(
                      label: 'Full Name',
                      hint: 'e.g. Rahul Sharma',
                      icon: Icons.person_outline_rounded,
                      controller: _nameController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Name is required';
                        if (v.trim().length < 2) return 'Enter a valid full name';
                        return null;
                      },
                    ),

                    // ── Department ────────────────────────────
                    _buildField(
                      label: 'Department',
                      hint: 'e.g. Computer Science',
                      icon: Icons.school_outlined,
                      controller: _deptController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Department is required';
                        return null;
                      },
                    ),

                    // ── Email ─────────────────────────────────
                    _buildField(
                      label: 'Email Address',
                      hint: 'student@example.com',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    // ── Password ──────────────────────────────
                    _buildField(
                      label: 'Password',
                      hint: 'Minimum 6 characters',
                      icon: Icons.lock_outline_rounded,
                      controller: _passwordController,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // ── Submit button ──────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _createStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          disabledBackgroundColor: _primary.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_created)
                                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22)
                                  else
                                    const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _created ? 'Account Created!' : 'Creating Account...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Create Student Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── How it works note ─────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _slate100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'How it works',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _slate900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildStep('1', 'Account is created in Firebase Authentication'),
                          _buildStep('2', 'Student profile & role stored in Firestore'),
                          _buildStep('3', 'Student logs in using the email & password above'),
                          _buildStep('4', 'App redirects them to the Student Dashboard'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(right: 10, top: 1),
            decoration: const BoxDecoration(color: _primaryLight, shape: BoxShape.circle),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(color: _slate500, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class CreateStudentScreen extends StatefulWidget {
  final String initialRole;
  const CreateStudentScreen({super.key, this.initialRole = 'student'});

  @override
  State<CreateStudentScreen> createState() => _CreateStudentScreenState();
}

class _CreateStudentScreenState extends State<CreateStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deptController = TextEditingController();
  final _employeeCodeController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;
  bool _created = false;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  static const Color _primary = Color(0xFF4F46E5);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate200 = Color(0xFFE2E8F0);
  static const Color _slate50 = Color(0xFFF8FAFC);

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _deptController.dispose();
    _employeeCodeController.dispose();
    super.dispose();
  }

  String _getRoleDisplayName(String role) {
    return role == 'student' ? 'Student' 
        : role == 'placementCell' ? 'Placement Cell' 
        : role;
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _authService.createUserByAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        fullName: _nameController.text.trim(),
        department: _deptController.text.trim(),
        employeeCode: _employeeCodeController.text.trim().isEmpty
            ? null
            : _employeeCodeController.text.trim(),
      );

      if (mounted) {
        setState(() => _created = true);
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          _clearForm();
          _showSuccess('${_getRoleDisplayName(_selectedRole)} account created!');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _loading = false);
      final msg = e.code == 'email-already-in-use'
          ? 'Email already registered'
          : e.code == 'weak-password'
          ? 'Password must be 6+ characters'
          : e.message ?? 'Error creating account';
      _showError('Failed', msg);
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _showError('Error', e.toString());
    }
  }

  void _clearForm() {
    setState(() {
      _loading = false;
      _created = false;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _deptController.clear();
      _employeeCodeController.clear();
      _selectedRole = 'student';
    });
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: _slate500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _slate900)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _hidePassword : false,
          style: const TextStyle(fontSize: 14, color: _slate900),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF94A3B8)),
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 1.5),
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
        title: const Text('Create User Account', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
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
                        Text('Create New User', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Add user with role and credentials', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text('Users login with these credentials', style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    Text('User Role', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _slate900)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: _slate200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        underline: const SizedBox(),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        items: const [
                          DropdownMenuItem(value: 'student', child: Text('Student')),
                          DropdownMenuItem(value: 'placementCell', child: Text('Placement Cell')),
                        ],
                        onChanged: (val) => setState(() => _selectedRole = val ?? 'student'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Full Name',
                      hint: 'e.g. Rahul Sharma',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      validator: (v) => v?.isEmpty ?? true ? 'Name required' : null,
                    ),
                    _buildField(
                      label: 'Department',
                      hint: 'e.g. Computer Science',
                      icon: Icons.school_outlined,
                      controller: _deptController,
                      validator: (v) => v?.isEmpty ?? true ? 'Department required' : null,
                    ),
                    _buildField(
                      label: 'Employee Code (Optional)',
                      hint: 'e.g. STU001',
                      icon: Icons.badge_outlined,
                      controller: _employeeCodeController,
                    ),
                    _buildField(
                      label: 'Email Address',
                      hint: 'user@example.com',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      validator: (v) => !v!.contains('@') ? 'Valid email required' : null,
                    ),
                    _buildField(
                      label: 'Password',
                      hint: 'Minimum 6 characters',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                      validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _createUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_created)
                                    const Icon(Icons.check_circle, color: Colors.white, size: 22)
                                  else
                                    const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    ),
                                  const SizedBox(width: 12),
                                  Text(_created ? 'Created!' : 'Creating...',
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add, color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text('Create Account',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.security_outlined, color: _primary, size: 18),
                              SizedBox(width: 8),
                              Text('Security', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _slate900)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '• Share credentials securely\n'
                            '• User can change password on first login\n'
                            '• Admin can deactivate accounts anytime',
                            style: TextStyle(fontSize: 12, color: _slate500, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
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
